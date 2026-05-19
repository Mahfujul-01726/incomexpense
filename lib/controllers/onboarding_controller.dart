import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;
  final pageController = PageController();

  final List<Map<String, String>> onboardingData = [
    {
      'title': 'Track Income & Expenses',
      'description': 'Easily monitor your daily spending, manage cash flow, and keep your budget in check with automated calculations.',
      'image': '1.png',
    },
    {
      'title': 'Visual Insights & Analytics',
      'description': 'Understand where your money goes with detailed statistics, visual charts, and category breakdowns.',
      'image': '2.png',
    },
    {
      'title': 'Manage All Your Wallets',
      'description': 'Link your checking accounts, credit cards, or cash wallets to see all your balances in one unified place.',
      'image': 'Cards.png',
    }
  ];

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.offAllNamed('/dashboard');
    }
  }
}
