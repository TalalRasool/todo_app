import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_icons.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/widgets/common_textfield.dart';



class AddlistScreen extends StatelessWidget {
  // TextFields ka data save rakhne ke liye controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
final TodoController _todoController = Get.put(TodoController());

  AddlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, right: 300),
                child: InkWell(
                  child: Icon(AppIcons.backArrow),
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Center(
                child: Text(
                  "Add new ToDo",
                  style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Image.asset(
                AppImages.addlist,
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                "Add what do you want later on",
                style: TextStyle(color: Colors.blueAccent, fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: CommonTextField(
                    controller: _titleController, 
                    hintText: "Title",
                   validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter task title";
          }
          return null;
        },
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10, top: 20),
                child: CommonTextField(
                    controller: _descriptionController,
                    hintText: "discription",
                    validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter task description";
          }
          return null;
        },
                    ),
              ),
              SizedBox(
                height: 20.h,
              ),
              ElevatedButton(
                  onPressed: () {
                    // Sirf navigation reh gayi hai, snackbar hata diya gaya hai
                   if (_formKey.currentState!.validate()) {
      // 2. Controller ka function call karein
      _todoController.addTodo(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
     Get.toNamed(RouteNames.mainscreen);
                  },
                  child: Obx(() {
      return _todoController.isLoading.value
          ? SizedBox(
              height: 24.h,
              width: 24.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
             
            )

          : Text(
              "Add your list",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            );

            
    }),)
            ],
          ),
        ),
      ),
    );
  }
}