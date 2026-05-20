import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  /// Reactive user observable
  final Rx<User?> user = Rx<User?>(null);

  /// Loading state for sign-in button
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind Firebase auth state changes to our reactive user
    user.bindStream(_authService.authStateChanges);
  }

  /// Whether a user is currently signed in
  bool get isLoggedIn => user.value != null;

  /// Sign in with Google, then navigate to dashboard
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final signedInUser = await _authService.signInWithGoogle();

      if (signedInUser != null) {
        // Mark onboarding as complete so splash goes to dashboard next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('onboarding_completed', true);

        Get.back(); // Close the bottom sheet
        Get.offAllNamed('/dashboard');
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

  /// Sign out and go back to onboarding
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      // Clear onboarding flag so they go through login again
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', false);
      Get.offAllNamed('/onboarding');
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
