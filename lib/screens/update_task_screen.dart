import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/todo_controller.dart';
import 'package:talal_todo/utils/app_snackbar.dart';
import 'package:talal_todo/widgets/common_textfield.dart';
import 'package:talal_todo/widgets/primary_button.dart';

class UpdateTaskScreen extends StatefulWidget {
  const UpdateTaskScreen({super.key});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final TodoController _todoController = Get.put(TodoController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final String docId;

  @override
  void initState() {
    super.initState();
    final data = Get.arguments is Map ? Get.arguments as Map : <String, dynamic>{};
    docId = data['docId']?.toString() ?? '';
    _titleController = TextEditingController(text: data['title']?.toString() ?? '');
    _descController = TextEditingController(
      text: data['description']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (docId.isEmpty) {
      AppSnackbar.error('Error', 'This task could not be opened.');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _todoController.updateTodo(
      docId,
      _titleController.text.trim(),
      _descController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Update Task')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task title',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              CommonTextField(
                controller: _titleController,
                hintText: 'Enter title',
                prefixIcon: const Icon(Icons.title, color: Colors.grey),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              Text(
                'Task description',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              CommonTextField(
                controller: _descController,
                hintText: 'Enter description',
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 28.h),
              PrimaryButton(label: 'Update task', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
