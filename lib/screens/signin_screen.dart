import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/widgets/common_textfield.dart';
import 'package:talal_todo/widgets/primary_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openSignup() {
    if (Get.previousRoute == RouteNames.signup) {
      Get.back();
      return;
    }
    Get.toNamed(RouteNames.signup);
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
                  SizedBox(height: 25.h),
                  Center(
                    child: Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: Image.asset(
                      AppImages.signin,
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 30.h),
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
                      return null;
                    },
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Get.toNamed(RouteNames.forgotPassword),
                      child: Text(
                        'Forget password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Obx(
                    () => PrimaryButton(
                      label: 'Sign In',
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
                        _authController.signIn(
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
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openSignup,
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
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
