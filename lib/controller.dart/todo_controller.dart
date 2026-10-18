import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/services/notification_service.dart';
import 'package:talal_todo/utils/app_snackbar.dart';
import 'package:talal_todo/utils/time_format.dart';

class TodoTask {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final DateTime createdAt;

  const TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isCompleted,
    required this.createdAt,
  });

  TodoTask copyWith({
    String? title,
    String? description,
    String? time,
    bool? isCompleted,
  }) {
    return TodoTask(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}

class TodoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final userName = ''.obs;
  final profileImageUrl = ''.obs;
  final isUploading = false.obs;
  final tasks = <TodoTask>[].obs;
  final tasksReady = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _todoSub;
  String? _listeningUid;
  final Map<String, TodoTask> _remoteTasks = {};
  final Map<String, TodoTask> _localTasks = {};
  final Set<String> _deletedIds = {};

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
    watchTodos();
  }

  @override
  void onClose() {
    _todoSub?.cancel();
    super.onClose();
  }

  Future<void> addTodo(String title, String description) async {
    if (isLoading.value) return;

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      1 << 30,
    );

    final createdAt = DateTime.now();
    final ref = _firestore.collection('users').doc(uid).collection('todos').doc();
    final task = TodoTask(
      id: ref.id,
      title: title,
      description: description,
      time: formatTaskTime(TimeOfDay.now()),
      isCompleted: false,
      createdAt: createdAt,
    );

    try {
      isLoading.value = true;
      _putLocalTask(task);
      _writeInBackground(
        ref.set({
          'title': title,
          'description': description,
          'time': task.time,
          'isCompleted': false,
          'notificationId': notificationId,
          'createdAt': Timestamp.fromDate(createdAt),
        }),
      );
      unawaited(
        NotificationService.scheduleNotification(
          id: notificationId,
          title: 'Task reminder',
          body: "Just checking in on your task: '$title'.",
        ),
      );
      Get.back();
      AppSnackbar.success('Success', 'Task added successfully');
    } catch (e) {
      debugPrint('Could not add task: $e');
      AppSnackbar.error('Error', 'Could not add the task. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void watchTodos() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      _todoSub?.cancel();
      _todoSub = null;
      _listeningUid = null;
      tasks.clear();
      _remoteTasks.clear();
      _localTasks.clear();
      _deletedIds.clear();
      tasksReady.value = true;
      return;
    }
    if (_listeningUid == uid && _todoSub != null) return;

    _listeningUid = uid;
    _todoSub?.cancel();
    _todoSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .listen(
          _applySnapshot,
          onError: (Object e) {
            debugPrint('Todo stream error: $e');
            tasksReady.value = true;
            _publishTasks();
          },
        );
  }

  Future<void> deleteTodo(String docId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    try {
      final ref = _todoRef(uid, docId);
      _deletedIds.add(docId);
      _localTasks.remove(docId);
      tasks.removeWhere((task) => task.id == docId);
      unawaited(_cancelReminder(ref));
      _writeInBackground(ref.delete());
      AppSnackbar.success('Deleted', 'Task removed.');
    } catch (e) {
      debugPrint('Could not delete task: $e');
      AppSnackbar.error('Error', 'Could not delete the task.');
    }
  }

  Future<void> updateTodo(String docId, String newTitle, String newDesc) async {
    if (docId.isEmpty) {
      AppSnackbar.error('Error', 'This task could not be opened.');
      return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    final index = tasks.indexWhere((task) => task.id == docId);
    final current = index >= 0 ? tasks[index] : null;
    final updated = (current ??
            TodoTask(
              id: docId,
              title: newTitle,
              description: newDesc,
              time: '',
              isCompleted: false,
              createdAt: DateTime.now(),
            ))
        .copyWith(title: newTitle, description: newDesc);

    try {
      isLoading.value = true;
      _putLocalTask(updated);
      _writeInBackground(
        _todoRef(uid, docId).update({
          'title': newTitle,
          'description': newDesc,
        }),
      );
      Get.back();
      AppSnackbar.success('Success', 'Task updated successfully');
    } catch (e) {
      debugPrint('Could not update task: $e');
      AppSnackbar.error('Error', 'Could not update the task.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      userName.value = '';
      profileImageUrl.value = '';
      return;
    }

    userName.value = _bestKnownName();
    final ref = _firestore.collection('users').doc(uid);

    try {
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (_auth.currentUser?.uid != uid) return;
      _applyProfile(cached.data());
    } catch (e) {
      debugPrint('No cached profile: $e');
    }

    unawaited(
      ref.get(const GetOptions(source: Source.server)).then((doc) {
        if (_auth.currentUser?.uid != uid) return;
        _applyProfile(doc.data());
      }).catchError((Object e) {
        debugPrint('Error fetching user data: $e');
      }),
    );
  }

  void _applyProfile(Map<String, dynamic>? data) {
    if (data == null) return;
    final name = _bestKnownName(profileName: data['name'] as String?);
    if (name.isNotEmpty) userName.value = name;
    final image = data['profileImage'];
    if (image is String && image.isNotEmpty) {
      profileImageUrl.value = image;
    }
  }

  String _bestKnownName({String? profileName}) {
    final profile = profileName?.trim() ?? '';
    if (profile.isNotEmpty) return profile;
    final display = _auth.currentUser?.displayName?.trim() ?? '';
    if (display.isNotEmpty) return display;
    return userName.value.trim();
  }

  Future<void> updateUserName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    final name = newName.trim();
    if (name.isEmpty) {
      AppSnackbar.error('Error', 'Name cannot be empty.');
      return;
    }

    try {
      userName.value = name;
      final user = _auth.currentUser;
      if (user != null) {
        unawaited(user.updateDisplayName(name));
      }
      _writeInBackground(
        _firestore.collection('users').doc(uid).set({
          'name': name,
        }, SetOptions(merge: true)),
      );
      AppSnackbar.success('Success', 'Name updated successfully.');
    } catch (e) {
      debugPrint('Could not update name: $e');
      AppSnackbar.error('Error', 'Could not update your name.');
    }
  }

  Future<void> uploadProfilePicture(ImageSource source) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 50,
      );
      if (image == null) return;

      isUploading.value = true;
      final bytes = await image.readAsBytes();
      final ref = FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      if (_auth.currentUser?.uid != uid) return;
      profileImageUrl.value = downloadUrl;
      AppSnackbar.success('Success', 'Profile picture updated.');
    } catch (e) {
      debugPrint('Could not upload profile picture: $e');
      AppSnackbar.error('Error', 'Could not update your profile picture.');
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      userName.value = '';
      profileImageUrl.value = '';
      isLoading.value = false;
      isUploading.value = false;
      watchTodos();
      Get.offAllNamed(RouteNames.signin);
    } catch (e) {
      debugPrint('Logout failed: $e');
      AppSnackbar.error('Error', 'Could not log out. Please try again.');
    }
  }

  Future<void> toggleTaskStatus(String docId, bool currentStatus) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      AppSnackbar.error('Error', 'Please sign in again.');
      return;
    }

    try {
      final ref = _todoRef(uid, docId);
      final completed = !currentStatus;
      final index = tasks.indexWhere((task) => task.id == docId);
      if (index >= 0) {
        _putLocalTask(tasks[index].copyWith(isCompleted: completed));
      }
      _writeInBackground(ref.update({'isCompleted': completed}));
      if (completed) {
        unawaited(_cancelReminder(ref));
      }
    } catch (e) {
      debugPrint('Could not update task status: $e');
      AppSnackbar.error('Error', 'Could not update task status.');
    }
  }

  void _putLocalTask(TodoTask task) {
    _deletedIds.remove(task.id);
    _localTasks[task.id] = task;
    _publishTasks();
  }

  void _applySnapshot(QuerySnapshot<Map<String, dynamic>> snap) {
    _remoteTasks
      ..clear()
      ..addAll({for (final doc in snap.docs) doc.id: _taskFromDoc(doc)});

    for (final id in _deletedIds.toList()) {
      if (!_remoteTasks.containsKey(id)) _deletedIds.remove(id);
    }

    for (final id in _localTasks.keys.toList()) {
      final local = _localTasks[id]!;
      final saved = _remoteTasks[id];
      if (saved != null && _sameTask(saved, local)) {
        _localTasks.remove(id);
      }
    }

    _publishTasks();
    tasksReady.value = true;
  }

  void _publishTasks() {
    final merged = <String, TodoTask>{..._remoteTasks};
    for (final entry in _localTasks.entries) {
      merged[entry.key] = entry.value;
    }
    merged.removeWhere((id, _) => _deletedIds.contains(id));
    final list = merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    tasks.assignAll(list);
  }

  TodoTask _taskFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final created = data['createdAt'];
    return TodoTask(
      id: doc.id,
      title: data['title'] as String? ?? 'No Title',
      description: data['description'] as String? ?? 'No Description',
      time: data['time'] as String? ?? '',
      isCompleted: data['isCompleted'] == true,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  bool _sameTask(TodoTask a, TodoTask b) {
    return a.title == b.title &&
        a.description == b.description &&
        a.time == b.time &&
        a.isCompleted == b.isCompleted;
  }

  void _writeInBackground<T>(Future<T> write) {
    unawaited(
      write.then<void>(
        (_) {},
        onError: (Object e, StackTrace _) {
          debugPrint('Could not sync write: $e');
        },
      ),
    );
  }

  DocumentReference<Map<String, dynamic>> _todoRef(String uid, String docId) {
    return _firestore.collection('users').doc(uid).collection('todos').doc(docId);
  }

  Future<void> _cancelReminder(DocumentReference<Map<String, dynamic>> ref) async {
    try {
      final snap = await ref.get();
      final raw = snap.data()?['notificationId'];
      final id = raw is int ? raw : (raw is num ? raw.toInt() : null);
      if (id != null) {
        await NotificationService.cancel(id);
      }
    } catch (e) {
      debugPrint('Could not cancel reminder: $e');
    }
  }
}
