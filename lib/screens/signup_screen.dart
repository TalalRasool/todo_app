import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/widgets/common_textfield.dart';
import 'package:talal_todo/widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openSignin() {
    if (Get.previousRoute == RouteNames.signin) {
      Get.back();
      return;
    }
    Get.toNamed(RouteNames.signin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      onPressed: Get.back,
                      icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
                    ),
                  SizedBox(height: 5.h),
                  Center(
                    child: Image.asset(
                      AppImages.onboarding,
                      height: 150.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Sign up to get started!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CommonTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  CommonTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15.h),
                  CommonTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPassword: true,
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 25.h),
                  Obx(
                    () => PrimaryButton(
                      label: 'Sign Up',
                      isLoading: _authController.isLoading.value,
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        final isValid = _formKey.currentState?.validate() ?? false;
                        if (!isValid) {
                          setState(() {
                            _autovalidateMode = AutovalidateMode.onUserInteraction;
                          });
                          return;
                        }
                        _authController.signUp(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text,
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      InkWell(
                        onTap: _openSignin,
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
