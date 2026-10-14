import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talal_todo/constants/app_colors.dart';
import 'package:talal_todo/constants/app_prefs.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TodoController _todoController = Get.put(TodoController());
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _notificationsOn = true;

  @override
  void initState() {
    super.initState();
    _todoController.fetchUserData();
    _loadNotificationPref();
  }

  Future<void> _loadNotificationPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsOn = prefs.getBool(AppPrefs.notificationsEnabled) ?? true;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notificationsOn = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefs.notificationsEnabled, value);
  }

  void _showPhotoOptions() {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Profile photo',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Get.back();
                  _todoController.uploadProfilePicture(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () {
                  Get.back();
                  _todoController.uploadProfilePicture(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  Future<void> _editName() async {
    final nameController = TextEditingController(
      text: _todoController.userName.value,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        var errorText = '';
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Edit name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText: errorText.isEmpty ? null : errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = nameController.text.trim();
                    if (value.isEmpty) {
                      setLocalState(() => errorText = 'Name cannot be empty.');
                      return;
                    }
                    Navigator.pop(context, value);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    nameController.dispose();
    if (name != null) {
      _todoController.updateUserName(name);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );
    if (shouldLogout == true) {
      _todoController.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Obx(() {
                      final imageUrl = _todoController.profileImageUrl.value;
                      final uploading = _todoController.isUploading.value;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 52.r,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                            backgroundImage: imageUrl.isEmpty
                                ? null
                                : NetworkImage(imageUrl),
                            onBackgroundImageError: imageUrl.isEmpty
                                ? null
                                : (_, _) {},
                            child: imageUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 56.sp,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          if (uploading)
                            SizedBox(
                              width: 28.r,
                              height: 28.r,
                              child: const CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          else
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 16.r,
                                backgroundColor: AppColors.primary,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Tap the photo to change it',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Obx(() {
                          final name = _todoController.userName.value.trim();
                          return Text(
                            name.isEmpty ? 'Add your name' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: name.isEmpty ? Colors.grey : Colors.black87,
                            ),
                          );
                        }),
                      ),
                      IconButton(
                        tooltip: 'Edit name',
                        onPressed: _editName,
                        icon: Icon(Icons.edit_outlined, color: AppColors.primary, size: 20.sp),
                      ),
                    ],
                  ),
                  Text(
                    currentUser?.email ?? 'No email found',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, color: AppColors.primary),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Switch(
                    value: _notificationsOn,
                    onChanged: _setNotifications,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
