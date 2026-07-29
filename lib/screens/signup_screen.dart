import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/routes/route_names.dart';

import '../widgets/common_icon.dart';
import '../widgets/common_textfield.dart';
import '../widgets/common_container.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  // Dependency Injection: AuthController ko yahan register aur put kar diya
  final AuthController _authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Corner Back Arrow
                  InkWell( 
                    onTap: () {
                      Get.back(); 
                    },
                    child: Icon(AppIcons.backArrow),
                  ),
                  SizedBox(height: 5.h),
                  
                  Center(
                    child: Image.asset(AppImages.forget),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  Text(
                    "Sign up to get started!",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // ==========================================
                  // 🔴 Name Field (Active Kar Diya Hai)
                  // ==========================================
                  CommonTextField(
                    controller: _nameController,
                    hintText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your full name";
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 15.h),
                  
                  // Email Field
                  CommonTextField(
                    controller: _emailController,
                    hintText: "Email Address",
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your email";
                      } else if (!GetUtils.isEmail(value.trim())) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 15.h),
                  
                  // Password Field
                  CommonTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    isPassword: true, 
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your password";
                      } else if (value.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 25.h),
                  
                  // Sign Up Button
                  CommonContainer(
                    width: double.infinity,
                    height: 50.h,
                    color: Colors.blueAccent,
                    borderRadius: 12.r,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // AuthController ka signUp function call kiya hai (with Name)
                        _authController.signUp(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    child: Center(
                      child: Obx(() {
                        return _authController.isLoading.value
                            ? SizedBox(
                                height: 24.h,
                                width: 24.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                      }),
                    ),
                  ),

                  SizedBox(height: 25.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      InkWell( 
                        onTap: () {
                          Get.toNamed(RouteNames.signin);
                        },
                        child: Padding(
                          padding: EdgeInsets.all(4.w), 
                          child: Text(
                            "Sign in",
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