import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
 
import '../widgets/common_textfield.dart';
import '../widgets/common_container.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  // 2. AuthController ko inject kiya
  final AuthController _authController = Get.put(AuthController());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _resetController = TextEditingController();

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
                      Get.back(); 
                    },
                    child: Icon(Icons.arrow_back_ios_new, size: 24.sp, color: Colors.black87),
                  ),

                  SizedBox(height: 40.h),

                  // Forget Password Picture
                  Center(
                    child: Image.asset(
                      'assets/images/forget.png', 
                      height: 220.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Screen Title
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Enter your email address to reset your password.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Email TextField
                  CommonTextField(
                    controller: _resetController,
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

                  SizedBox(height: 40.h),

                  // Forget Password Button
                  CommonContainer(
                    width: double.infinity,
                    height: 50.h,
                    color: Colors.blueAccent,
                    borderRadius: 12.r,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        // 3. Controller ka forgetPassword function call kiya
                        _authController.forgetPassword(_resetController.text.trim());
                      }
                    },
                    // 4. Obx lagaya loading state ke liye
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
                                "Send Reset Link",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                      }),
                    ),
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