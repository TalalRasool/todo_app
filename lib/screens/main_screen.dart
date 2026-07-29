import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/routes/route_names.dart';


import '../widgets/common_container.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final TodoController _todoController = Get.put(TodoController());

  final List<Color> taskColors = [
Colors.blue.shade50,
  Colors.orange.shade50,
  Colors.green.shade50,
  Colors.purple.shade50,
  Colors.pink.shade50,
  Colors.teal.shade50,
  Colors.red.shade50,
  Colors.cyan.shade50,
  Colors.amber.shade50,
  Colors.indigo.shade50,
  Colors.lightBlue.shade50,
  Colors.lightGreen.shade50,
  Colors.lime.shade50,
  Colors.yellow.shade50,
  Colors.deepOrange.shade50,
  Colors.deepPurple.shade50,
  Colors.brown.shade50,
  Colors.blueGrey.shade50,
  Colors.blue.shade100,
  Colors.green.shade100,
  Colors.orange.shade100,
  Colors.purple.shade100,
  Colors.pink.shade100,
  Colors.teal.shade100,
  Colors.indigo.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(RouteNames.addlist);
        },
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Blue Header Container
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 60.h, bottom: 30.h, left: 20.w, right: 20.w,
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Get.toNamed(RouteNames.profile);
                  },
                  child: Obx(() {
                    return CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white,
                      backgroundImage: _todoController.profileImageUrl.value.isNotEmpty
                          ? NetworkImage(_todoController.profileImageUrl.value)
                          : null,
                      child: _todoController.profileImageUrl.value.isEmpty
                          ? Icon(Icons.person, size: 45.sp, color: Colors.blueAccent)
                          : null,
                    );
                  }),
                ),
                
                SizedBox(height: 15.h),
                
                Obx(() => Text(
                  "Welcome ${_todoController.userName.value.isNotEmpty ? _todoController.userName.value : ''}",
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                )),
              ],
            ),
          ),

          SizedBox(height: 25.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              "Todo Tasks",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),

          SizedBox(height: 15.h),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _todoController.getTodos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No tasks added yet!", style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                  );
                }
                final tasks = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                  itemCount: tasks.length, 
                  itemBuilder: (context, index) {
                    var taskData = tasks[index].data() as Map<String, dynamic>;
                    String docId = tasks[index].id; 
                    String title = taskData['title'] ?? "No Title";
                    String description = taskData['description'] ?? "No Description";
                    String time = taskData['time'] ?? "";
                    
                    // 🔴 Check karo ke task complete hai ya nahi (agar database mein nahi hai toh default false)
                    bool isCompleted = taskData['isCompleted'] ?? false;

                    Color cardColor = taskColors[index % taskColors.length];

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteNames.updateTask, arguments: {
                          'docId': docId,
                          'title': title,
                          'description': description,
                        });
                      },
                      child: CommonContainer(
                        margin: EdgeInsets.only(bottom: 15.h),
                        padding: EdgeInsets.all(10.w), // Thori padding adjust ki hai
                        color: cardColor, 
                        borderRadius: 15.r,
                        showShadow: true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            
                            // ==========================================
                            // 🔴 CHECKBOX (Task Complete karne ke liye)
                            // ==========================================
                            Checkbox(
                              value: isCompleted,
                              activeColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                              onChanged: (value) {
                                // Controller ko batao ke status change karo
                                _todoController.toggleTaskStatus(docId, isCompleted);
                              },
                            ),

                            // Center: Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title, 
                                    style: TextStyle(
                                      fontSize: 16.sp, 
                                      fontWeight: FontWeight.bold, 
                                      // Agar complete hai toh line laga do aur color grey kar do
                                      color: isCompleted ? Colors.grey : Colors.black87,
                                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 5.h),
                                  Text(
                                    description, 
                                    style: TextStyle(
                                      fontSize: 13.sp, 
                                      color: isCompleted ? Colors.grey.shade400 : Colors.grey.shade700,
                                      decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                    ),
                                    maxLines: 2, overflow: TextOverflow.ellipsis, 
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(width: 5.w),

                            // Right Side: Time & Delete
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  time, 
                                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black54),
                                ),
                                SizedBox(height: 8.h),
                                GestureDetector(
                                  onTap: () {
                                    Get.defaultDialog(
                                      title: "Delete Task",
                                      titleStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18.sp),
                                      middleText: "Are you sure you want to delete this task?",
                                      textCancel: "No",
                                      textConfirm: "Yes",
                                      confirmTextColor: Colors.white,
                                      buttonColor: Colors.redAccent,
                                      onConfirm: () {
                                        Get.back(); 
                                        _todoController.deleteTodo(docId); 
                                      },
                                    );
                                  },
                                  child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 22.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}