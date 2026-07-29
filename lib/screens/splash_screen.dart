import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';// GetX import kiya
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // 3 second baad agli screen par bhejne ka function
  void _navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () {
      // GetX ki navigation: Get.offAll purani screens ko memory se nikal deta hai
      // 1. Firebase se puchen ke kya koi user logged-in hai?
 final  User? user = FirebaseAuth.instance.currentUser;
  
  // 2. Condition lagayen
  if (user != null) {
    // Agar user pehle se login hai, toh seedha Main Screen par bhej dein
    Get.offAllNamed(RouteNames.mainscreen);
  } else {
    // Agar login nahi hai (ya logout kar chuka hai), toh Login Screen par bhej dein
    Get.offAllNamed(RouteNames.signup); // Jo bhi aapka login route hai
  }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Updated Path: assets/app_images/splash.png
        Image.asset(AppImages.splash),
            
            SizedBox(height: 30.h), 

            Text(
              " Todo ",
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent, 
                letterSpacing: 2.0,
              ),
            ),
            
            SizedBox(height: 50.h),
            
            const CircularProgressIndicator(
              color: Colors.blueAccent,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}