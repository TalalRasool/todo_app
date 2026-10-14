import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/widgets/common_textfield.dart';
import 'package:talal_todo/widgets/primary_button.dart';

class AddlistScreen extends StatefulWidget {
  const AddlistScreen({super.key});

  @override
  State<AddlistScreen> createState() => _AddlistScreenState();
}

class _AddlistScreenState extends State<AddlistScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TodoController _todoController = Get.put(TodoController());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_todoController.isLoading.value) return;
    if (_formKey.currentState?.validate() ?? false) {
      _todoController.addTodo(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Add Task')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Image.asset(
                  AppImages.addlist,
                  height: 150.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add what you want to do later',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                ),
                SizedBox(height: 20.h),
                CommonTextField(
                  controller: _titleController,
                  hintText: 'Title',
                  prefixIcon: const Icon(Icons.title, color: Colors.grey),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                CommonTextField(
                  controller: _descriptionController,
                  hintText: 'Description',
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a task description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Obx(
                  () => PrimaryButton(
                    label: 'Add task',
                    isLoading: _todoController.isLoading.value,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
