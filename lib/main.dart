import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/firebase_options.dart';
import 'package:talal_todo/routes/app_routes.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/services/notification_service.dart';
import 'package:talal_todo/theme/app_theme.dart'; 



void main() async {
  // 1. Flutter engine ko ensure karein 
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase ko start (initialize) karein
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firestore persistence: $e');
  }

  try {
    await NotificationService.init();
  } catch (e, stack) {
    debugPrint('Notification init failed: $e\n$stack');
  }

  Get.put(AuthController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo',
          theme: AppTheme.light(),
          initialRoute: RouteNames.splashScreen,
          getPages: AppRoutes.appRoutes(),
        );
      },
    );
  }
}