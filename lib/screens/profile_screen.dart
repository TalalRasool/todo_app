import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TodoController _todoController = Get.find<TodoController>();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Screen open hote hi latest name Firebase se fetch karo
_todoController.fetchUserData();  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 24.sp),
        ),
        title: Text(
          "My Profile",
          style: TextStyle(color: Colors.black87, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            // 1. Profile Picture
            Center(
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.person, size: 60.sp, color: Colors.blueAccent),
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // ==========================================
            // 🔴 2. USER NAME WITH EDIT BUTTON
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Obx lagaya hai taa ke jab name update ho toh foran screen par change ho jaye
                Obx(() => Text(
                  _todoController.userName.value, 
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                )),
                
                SizedBox(width: 10.w),
                
                // Edit (Pencil) Icon
                GestureDetector(
                  onTap: () {
                    // Ek chota controller banaya taa ke purana name box mein pehle se likha aaye
                    TextEditingController nameController = TextEditingController(text: _todoController.userName.value);
                    
                    // Popup Dialog Box
                    Get.defaultDialog(
                      title: "Edit Name",
                      titleStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: "Enter your name",
                            prefixIcon: const Icon(Icons.person, color: Colors.grey),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                      ),
                      textCancel: "Cancel",
                      textConfirm: "Save",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.blueAccent,
                      onConfirm: () {
                        if (nameController.text.trim().isNotEmpty) {
                          // Controller ka update name wala function call karo
                          _todoController.updateUserName(nameController.text.trim());
                        } else {
                          Get.snackbar("Error", "Name cannot be empty!", backgroundColor: Colors.red.shade100);
                        }
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.edit, color: Colors.blueAccent, size: 18.sp),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
            
            // 3. User Email
            Text(
              currentUser?.email ?? "No Email Found",
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
            ),
            
            const Spacer(), 
            
            // 4. Logout Button
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  elevation: 3, 
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: "Logout",
                    titleStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18.sp),
                    middleText: "Are you sure you want to logout?",
                    textCancel: "Cancel",
                    textConfirm: "Yes, Logout",
                    cancelTextColor: Colors.black87,
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.redAccent,
                    onConfirm: () {
                      _todoController.logout();
                    },
                  );
                },
                icon: Icon(Icons.logout, color: Colors.white, size: 26.sp),
                label: Text(
                  "Log Out",
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}