import 'package:get/get.dart';
import '../pages/splash/splash_view.dart';
import '../pages/onboarding/onboarding_view.dart';
import '../pages/auth/signin/signin_view.dart';
import '../pages/dashboard/dashboard_view.dart';
import '../pages/bills/bills_view.dart';
import '../bindings/onboarding_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/bills_binding.dart';
import 'routes.dart';

class Pages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.signin,
      page: () => const SignInScreen(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.bills,
      page: () => const BillsScreen(),
      binding: BillsBinding(),
    ),
  ];
}
