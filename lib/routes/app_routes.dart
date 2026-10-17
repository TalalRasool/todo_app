
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:talal_todo/screens/addlist_screen.dart';
import 'package:talal_todo/screens/forget_screen.dart';
import 'package:talal_todo/screens/main_screen.dart';
import 'package:talal_todo/screens/onbording_screen.dart';
import 'package:talal_todo/screens/profile_screen.dart';
import 'package:talal_todo/screens/signin_screen.dart';
import 'package:talal_todo/screens/signup_screen.dart';
import 'package:talal_todo/screens/splash_screen.dart';
import 'package:talal_todo/screens/update_task_screen.dart';


import 'route_names.dart';

class AppRoutes {
  // Yahan List<GetPage> add karne se wo error hamesha ke liye khatam ho jayega
  static List<GetPage> appRoutes() => [
        // auth routes
        GetPage(name: RouteNames.splashScreen, page: () => const SplashScreen()),

        GetPage(name: RouteNames.onbording, page: () => const OnboardingScreen()),
        
        // Inko baad mein jab banayenge toh un-comment kar lenge
        GetPage(name: RouteNames.signup, page: () => const SignupScreen()),
        GetPage(name: RouteNames.signin, page: () => const SigninScreen()),

        GetPage(
          name: RouteNames.forgotPassword,
          page: () => const ForgetPasswordScreen(),
        ),
        GetPage(name: RouteNames.addlist, page: () => const AddlistScreen()),
        GetPage(name: RouteNames.updateTask, page: () => const UpdateTaskScreen()),
        GetPage(name: RouteNames.profile, page: () => const ProfileScreen()),
        GetPage(name: RouteNames.mainscreen, page: () => const MainScreen()),
      ];
}
