import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/routes/route_names.dart';
// RouteNames ko import kiy

import '../widgets/common_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPageIndex = 0;

  // Onboarding data (app_images folder ka path)
  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding.png",
      "title": "Organize Your Tasks",
      "description": "Keep track of all your daily tasks and activities easily in one place."
    },
    {
      "image": "assets/images/onboarding.png",
      "title": "Set Reminders",
      "description": "Never miss a deadline. Set reminders for your important tasks."
    },
    {
      "image": "assets/images/onboarding.png",
      "title": "Achieve Your Goals",
      "description": "Complete tasks, track your progress, and achieve your goals faster."
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Swipe karne wala hissa (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    imagePath: _onboardingData[index]["image"]!,
                    title: _onboardingData[index]["title"]!,
                    description: _onboardingData[index]["description"]!,
                  );
                },
              ),
            ),

            // 2. Dots aur Button wala hissa
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h), // ScreenUtil for Padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),

                  // Next / Get Started Button
                  CommonContainer(
                    width: 130.w, // ScreenUtil for Width
                    height: 50.h, // ScreenUtil for Height
                    color: Colors.blueAccent,
                    borderRadius: 25.r, // ScreenUtil for Radius
                    onTap: () {
                      if (_currentPageIndex == _onboardingData.length - 1) {
                        // GetX Navigation: Signup screen par jane ke liye
                        // Get.offAllNamed use kiya hai taa ke user wapas onboarding par na aa sake
                        Get.offAllNamed(RouteNames.signup); 
                        
                      } else {
                        // Agle page par jayen
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        _currentPageIndex == _onboardingData.length - 1
                            ? "Get Started"
                            : "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp, // ScreenUtil for Font Size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Har ek slide ka design
  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.onboarding),
          SizedBox(height: 40.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Dots ka design
  Widget _buildDotIndicator(int index) {
    bool isActive = _currentPageIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(right: 8.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? Colors.blueAccent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4.r), // ScreenUtil for dot radius
      ),
    );
  }
}