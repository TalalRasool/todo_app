import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/constants/app_prefs.dart';
import 'package:talal_todo/routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _openNext();
  }

  Future<void> _openNext() async {
    final userFuture = _currentUser();
    final prefsFuture = SharedPreferences.getInstance();
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    final user = await userFuture;
    final prefs = await prefsFuture;
    if (!mounted) return;

    if (user != null) {
      Get.offAllNamed(RouteNames.mainscreen);
      return;
    }

    final seenOnboarding = prefs.getBool(AppPrefs.seenOnboarding) ?? false;
    Get.offAllNamed(
      seenOnboarding ? RouteNames.signin : RouteNames.onbording,
    );
  }

  Future<User?> _currentUser() async {
    try {
      return await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => FirebaseAuth.instance.currentUser,
      );
    } catch (e) {
      debugPrint('Auth state check failed: $e');
      return FirebaseAuth.instance.currentUser;
    }
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
          children: [
            Image.asset(AppImages.splash),
            SizedBox(height: 30.h),
            Text(
              'Todo',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 50.h),
            const CircularProgressIndicator(strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
