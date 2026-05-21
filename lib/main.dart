import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/wallet_controller.dart';
import 'controllers/transaction_controller.dart';
import 'controllers/bill_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/onboarding_controller.dart';
import 'views/home/home_tab.dart';

// Views
import 'views/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/auth/signin_screen.dart';
import 'views/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Preferences
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

  // Initialize Global GetX Controllers
  Get.put(AuthController());
  Get.put(ProfileController());
  Get.put(WalletController());
  Get.put(TransactionController());
  Get.put(BillController());
  Get.put(OnboardingController());
  Get.put(NavigationController());

  runApp(MyApp(onboardingCompleted: onboardingCompleted));
}

class MyApp extends StatelessWidget {
  final bool onboardingCompleted;

  const MyApp({super.key, required this.onboardingCompleted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Income & Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/onboarding',
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: '/signin',
          page: () => const SignInScreen(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => DashboardScreen(),
        ),
      ],
    );
  }
}
