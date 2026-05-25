import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/preferences_service.dart';
import '../../routes/routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authService.authStateChanges);
  }

  bool get isLoggedIn => user.value != null;

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final signedInUser = await _authService.signInWithGoogle();
      if (signedInUser != null) {
        final prefsService = Get.find<PreferencesService>();
        await prefsService.setOnboardingCompleted(true);
        Get.offAllNamed(Routes.dashboard);
      }
    } catch (e) {
      Get.snackbar(
        'Sign-In Failed',
        'Could not sign in with Google. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      final prefsService = Get.find<PreferencesService>();
      await prefsService.setOnboardingCompleted(false);
      Get.offAllNamed(Routes.onboarding);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not sign out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
