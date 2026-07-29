import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/services/notification_service.dart';

class TodoController extends GetxController {
  static TodoController instance = Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  // 🔴 1. Name save karne ke liye GetX ka variable (Default khali kar diya hai)
  RxString userName = "".obs; 
  
  // 🔴 Image ka link save karne ke liye variable
  RxString profileImageUrl = "".obs; 
  RxBool isUploading = false.obs; // Loading animation ke liye

  // ==========================================
  // 🔴 APP KHULTE HI CHALNE WALA FUNCTION
  // ==========================================
  @override
  void onInit() {
    super.onInit();
    // App open hote hi Name aur Picture Firebase se utha lo
    fetchUserData(); 
  }

  // ==========================================
  // ADD TODO FUNCTION
  // ==========================================
  Future<void> addTodo(String title, String description) async {
    try {
      isLoading.value = true;
      
      // Current user ki ID get karein
      String uid = _auth.currentUser!.uid;
      
      // Current system time get karein task ke liye
      String timeNow = "${TimeOfDay.now().hour}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period.name.toUpperCase()}";

      // Firestore mein user ke specific document ke andar 'todos' collection mein data save karein
      await _firestore.collection('users').doc(uid).collection('todos').add({
        'title': title,
        'description': description,
        'time': timeNow,
        'createdAt': FieldValue.serverTimestamp(), // Sorting ke kaam aayega
      });

      // 🔴 12-Hour Notification Set Karna
      int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000; 
      
      await NotificationService.scheduleNotification(
        id: notificationId,
        title: "Task Reminder 📌",
        body: "Just checking in on your task: '$title'. If it's completed, don't forget to mark it as done!",
      );

      Get.snackbar(
        "Success", 
        "Task added & reminder set for 12 hours!", 
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      
      Get.offAllNamed(RouteNames.mainscreen);
      
    } catch (e) {
      Get.snackbar(
        "Error", 
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white, 
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // GET TODOS FUNCTION
  // ==========================================
  Stream<QuerySnapshot> getTodos() {
    String uid = _auth.currentUser!.uid;
    
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
  
  // ==========================================
  // DELETE TODO FUNCTION
  // ==========================================
  Future<void> deleteTodo(String docId) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .delete();

      Get.snackbar(
        "Deleted", 
        "Task removed successfully!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white, // Text white kiya taa ke nazar aaye
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error", 
        e.toString(),
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
    }
  }

  // ==========================================
  // UPDATE TODO FUNCTION
  // ==========================================
  Future<void> updateTodo(String docId, String newTitle, String newDesc) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('todos')
          .doc(docId)
          .update({
        'title': newTitle,
        'description': newDesc,
      });

      Get.back(); 
      
      Get.snackbar(
        "Updated", 
        "Task updated successfully!",
        backgroundColor: Colors.green.withValues(), // transparency hata di
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ==========================================
  // 🔴 FETCH USER DATA (Name & Image)
  // ==========================================
  Future<void> fetchUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('name')) {
          userName.value = data['name']; 
        }
        if (data.containsKey('profileImage')) {
          profileImageUrl.value = data['profileImage']; // Picture ka link UI ko do
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // ==========================================
  // 🔴 UPDATE USER NAME
  // ==========================================
  Future<void> updateUserName(String newName) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      await _firestore.collection('users').doc(uid).set({
        'name': newName,
      }, SetOptions(merge: true)); 
      
      userName.value = newName; 
      Get.back(); 
      
      Get.snackbar("Success", "Name updated successfully!", 
        backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ==========================================
  // 🔴 UPLOAD PROFILE PICTURE
  // ==========================================
  Future<void> uploadProfilePicture(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 50);

      if (image != null) {
        isUploading.value = true; 
        String uid = _auth.currentUser!.uid;
        File file = File(image.path);

        Reference ref = FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpg');
        await ref.putFile(file);

        String downloadUrl = await ref.getDownloadURL();

        await _firestore.collection('users').doc(uid).set({
          'profileImage': downloadUrl,
        }, SetOptions(merge: true));

        profileImageUrl.value = downloadUrl;
        isUploading.value = false; 
        
        Get.snackbar("Success", "Profile Picture Updated!", 
            backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
      }
    } catch (e) {
      isUploading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  // ==========================================
  // LOGOUT FUNCTION
  // ==========================================
  Future<void> logout() async {
    try {
      await _auth.signOut(); 
      Get.offAllNamed(RouteNames.signin); 
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // ==========================================
  // TASK COMPLETE KARTNE WALA FUNCTION
  // ==========================================
  Future<void> toggleTaskStatus(String docId, bool currentStatus) async {
    try {
      String uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).collection('todos').doc(docId).update({
        'isCompleted': !currentStatus,
      });
    } catch (e) {
      Get.snackbar("Error", "Could not update task status.");
    }
  }
}