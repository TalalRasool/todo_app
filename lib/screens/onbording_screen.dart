import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talal_todo/constants/app_images.dart';
import 'package:talal_todo/constants/app_prefs.dart';
import 'package:talal_todo/routes/route_names.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Organize Your Tasks',
      'description':
          'Keep track of all your daily tasks and activities easily in one place.',
    },
    {
      'title': 'Set Reminders',
      'description':
          'Never miss a deadline. A reminder is set 12 hours after you add a task.',
    },
    {
      'title': 'Achieve Your Goals',
      'description':
          'Complete tasks, track your progress, and keep your list moving.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppPrefs.seenOnboarding, true);
    Get.offAllNamed(RouteNames.signup);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPageIndex == _onboardingData.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text('Skip', style: TextStyle(fontSize: 15.sp)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppImages.onboarding,
                          height: 220.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 36.h),
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _onboardingData[index]['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) {
                        final isActive = _currentPageIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(right: 8.w),
                          height: 8.h,
                          width: isActive ? 24.w : 8.w,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        );
                      },
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48.h,
                    child: FilledButton(
                      onPressed: () {
                        if (isLastPage) {
                          _finish();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: Text(isLastPage ? 'Get Started' : 'Next'),
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
}
