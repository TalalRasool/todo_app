import 'dart:math'; // 🔴 Random colors pick karne ke liye add kiya
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import '../widgets/common_container.dart';

class UpdateTaskScreen extends StatefulWidget {
  const UpdateTaskScreen({super.key});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final TodoController _todoController = Get.find<TodoController>();
  
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late String docId;

  // 🔴 Colors save karne ke liye variables
Color titleColor = Colors.white;
  Color descColor = Colors.white;

  // 🔴 Khoobsurat light colors ki list
  final List<Color> randomColors = [
    Colors.blue.shade50,
    Colors.orange.shade50,
    Colors.green.shade50,
    Colors.purple.shade50,
    Colors.pink.shade50,
    Colors.teal.shade50,
  ];

  @override
  void initState() {
    super.initState();
    
    var data = Get.arguments ?? {};
    docId = data['docId'] ?? '';
    _titleController = TextEditingController(text: data['title'] ?? '');
    _descController = TextEditingController(text: data['description'] ?? '');

    // 🔴 Screen open hote hi random color pick karna
    final random = Random();
    titleColor = randomColors[random.nextInt(randomColors.length)];
    descColor = randomColors[random.nextInt(randomColors.length)];
    
    // Logic: Agar dono colors same aa jayen, toh description ka color change kar do
    while (descColor == titleColor) {
      descColor = randomColors[random.nextInt(randomColors.length)];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

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
          "Update Task",
          style: TextStyle(color: Colors.black87, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text("Task Title", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              SizedBox(height: 8.h),
              
              // ==========================================
              // 🔴 TITLE TEXT FIELD (With Random Color)
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: titleColor, // Random color apply
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: "Enter title",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.title, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              Text("Task Description", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
              SizedBox(height: 8.h),
              
              // ==========================================
              // 🔴 DESCRIPTION TEXT FIELD (With Random Color)
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: descColor, // Random color apply
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: TextFormField(
                  controller: _descController,
                  maxLines: 5,
                  style: TextStyle(fontSize: 15.sp),
                  decoration: InputDecoration(
                    hintText: "Enter description",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.description_outlined, color: Colors.grey),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  ),
                ),
              ),
              
              SizedBox(height: 40.h),
              
              // ==========================================
              // UPDATE BUTTON
              // ==========================================
              CommonContainer(
                width: double.infinity,
                height: 50.h,
                color: Colors.blueAccent,
                borderRadius: 12.r,
                onTap: () {
                  if (_titleController.text.trim().isNotEmpty && _descController.text.trim().isNotEmpty) {
                    _todoController.updateTodo(
                      docId, 
                      _titleController.text.trim(), 
                      _descController.text.trim(),
                    );
                  } else {
                    Get.snackbar(
                      "Error", 
                      "Fields cannot be empty!",
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      colorText: Colors.redAccent,
                    );
                  }
                },
                child: Center(
                  child: Text(
                    "Update Task",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}