import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:talal_todo/controller.dart/auth_controller.dart';
import 'package:talal_todo/firebase_options.dart';
import 'package:talal_todo/routes/app_routes.dart';
import 'package:talal_todo/routes/route_names.dart';
import 'package:talal_todo/services/notification_service.dart'; 



void main() async {
  // 1. Flutter engine ko ensure karein 
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase ko start (initialize) karein
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==========================================
  // 🔴 3. NOTIFICATION SYSTEM START KAREIN
  // ==========================================
  await NotificationService.init();

  // 4. Firebase start hone ke baad AuthController ko memory mein daalein
  Get.put(AuthController());

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
          initialRoute: RouteNames.splashScreen,
          getPages: AppRoutes.appRoutes(),
        );
      },
    );
  }
}