import 'package:get/get.dart';
import '../../services/preferences_service.dart';
import '../../routes/routes.dart';

class OnboardingController extends GetxController {
  final PreferencesService _prefsService = Get.find<PreferencesService>();

  void completeOnboarding() => Get.toNamed(Routes.signin);

  Future<void> finishOnboarding() async {
    try {
      await _prefsService.setOnboardingCompleted(true);
    } catch (_) {}
    Get.offAllNamed(Routes.dashboard);
  }
}
