import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/preferences_service.dart';
import '../../routes/routes.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _navigateToNext();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    animationController.forward();
  }

  Future<void> _navigateToNext() async {
    try {
      await Future.delayed(const Duration(milliseconds: 2500));

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        Get.offAllNamed(Routes.dashboard);
        return;
      }

      final prefsService = Get.find<PreferencesService>();
      final onboardingCompleted = await prefsService.getOnboardingCompleted();

      if (onboardingCompleted) {
        Get.offAllNamed(Routes.dashboard);
      } else {
        Get.offAllNamed(Routes.onboarding);
      }
    } catch (e) {
      Get.offAllNamed(Routes.onboarding);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
