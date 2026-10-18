import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_colors.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TodoController _todoController;

  @override
  void initState() {
    super.initState();
    _todoController = Get.put(TodoController());
    _todoController.fetchUserData();
    _todoController.watchTodos();
    _showWelcomeNotificationOnce();
  }

  void _showWelcomeNotificationOnce() {
    if (!AuthController.pendingWelcomeNotification) return;
    AuthController.pendingWelcomeNotification = false;
    final pending = AuthController.pendingWelcomeName?.trim() ?? '';
    AuthController.pendingWelcomeName = null;
    unawaited(_deliverWelcome(pending));
  }

  Future<void> _deliverWelcome(String pending) async {
    if (pending.isNotEmpty) {
      _todoController.userName.value = pending;
      await NotificationService.showWelcome(pending);
      return;
    }

    await _todoController.fetchUserData();
    final saved = _todoController.userName.value.trim();
    final displayName =
        FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
    final name = saved.isNotEmpty ? saved : displayName;
    await NotificationService.showWelcome(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add task',
        onPressed: () => Get.toNamed(RouteNames.addlist),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 20.h,
        bottom: 24.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: InkWell(
        onTap: () => Get.toNamed(RouteNames.profile),
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            Obx(() {
              final imageUrl = _todoController.profileImageUrl.value;
              return CircleAvatar(
                radius: 36.r,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
                onBackgroundImageError: imageUrl.isEmpty ? null : (_, _) {},
                child: imageUrl.isEmpty
                    ? Icon(Icons.person, size: 40.sp, color: AppColors.primary)
                    : null,
              );
            }),
            SizedBox(height: 12.h),
            Obx(() {
              final savedName = _todoController.userName.value.trim();
              final authName =
                  FirebaseAuth.instance.currentUser?.displayName?.trim() ?? '';
              final name = savedName.isNotEmpty ? savedName : authName;
              return Text(
                name.isEmpty ? 'Welcome' : 'Welcome, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }),
            SizedBox(height: 4.h),
            Text(
              'View profile',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (FirebaseAuth.instance.currentUser == null) {
      return _messageState(
        icon: Icons.lock_outline,
        title: 'Sign in to see your tasks',
        message: 'Your tasks stay private to your account.',
      );
    }

    return Obx(() {
        final taskItems = _todoController.tasks.toList();
        if (!_todoController.tasksReady.value && taskItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        var open = 0;
        var done = 0;
        for (final task in taskItems) {
          if (task.isCompleted) {
            done++;
          } else {
            open++;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'Todo Tasks',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  _countChip('$open open'),
                  SizedBox(width: 8.w),
                  _countChip('$done done'),
                ],
              ),
            ),
            Expanded(
              child: taskItems.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks added yet',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 96.h),
                      itemCount: taskItems.length,
                      itemBuilder: (context, index) {
                        return _taskCard(taskItems[index], index);
                      },
                    ),
            ),
          ],
        );
    });
  }

  Widget _countChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _messageState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84.r,
              height: 84.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38.sp, color: AppColors.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskCard(TodoTask task, int index) {
    final docId = task.id;
    final title = task.title;
    final description = task.description;
    final time = task.time;
    final isCompleted = task.isCompleted;
    final accent = AppColors.taskAccents[index % AppColors.taskAccents.length];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5.w,
                color: isCompleted ? Colors.grey.shade300 : accent,
              ),
              Checkbox(
                value: isCompleted,
                onChanged: (_) {
                  _todoController.toggleTaskStatus(docId, isCompleted);
                },
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Get.toNamed(
                      RouteNames.updateTask,
                      arguments: {
                        'docId': docId,
                        'title': title,
                        'description': description,
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isCompleted ? Colors.grey : Colors.black87,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            height: 1.3,
                            color: isCompleted
                                ? Colors.grey.shade400
                                : Colors.grey.shade700,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 8.w, left: 4.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black45,
                        ),
                      ),
                    IconButton(
                      tooltip: 'Delete task',
                      onPressed: () => _confirmDelete(docId),
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColors.danger,
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String docId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _todoController.deleteTodo(docId);
    }
  }
}
