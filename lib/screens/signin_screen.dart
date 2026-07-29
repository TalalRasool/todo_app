import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/routes/route_names.dart';

 // 1. AuthController import kiya

import '../widgets/common_textfield.dart';
import '../widgets/common_container.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  // 2. Dependency Injection: AuthController register kiya
  final AuthController _authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Name ki jagah Email controller use hoga login ke liye
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
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteNames.signup); 
                    },
                    child: Icon(Icons.arrow_back_ios_new, size: 24.sp), 
                  ),

                  SizedBox(height: 25.h),

                  // Center Text "Welcome Back"
                  Center(
                    child: Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Sign In Screen Picture
                  Center(
                    child: Image.asset(
                      'assets/images/signin.png', 
                      height: 200.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Email TextField (Updated for Firebase Login)
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

                  // Password TextField
                  CommonTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    isPassword: true, 
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 10.h),

                  // Forget Password Text
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteNames.forgotPassword);
                      },
                      child: Text(
                        "Forget password?",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Sign In Button
                  CommonContainer(
                    width: double.infinity,
                    height: 50.h,
                    color: Colors.blueAccent,
                    borderRadius: 12.r,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // 3. AuthController ka signIn function call kiya
                        _authController.signIn(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      }
                    },
                    // 4. Obx lagaya taa ke loading state manage ho sake
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
                                "Sign In",
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

                  // Don't have an account? Sign Up 
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
                        onTap: () {
                          Get.toNamed(RouteNames.signup);
                        },
                        child: Text(
                          "Sign up",
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