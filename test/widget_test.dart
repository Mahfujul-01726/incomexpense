// This is a basic Flutter widget test for the Income & Expense Tracker.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:incomexpense/controllers/onboarding_controller.dart';
import 'package:incomexpense/views/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders slides and controls', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Inject controller
    Get.put(OnboardingController());

    // Build the widget directly inside a GetMaterialApp
    await tester.pumpWidget(const GetMaterialApp(
      home: OnboardingScreen(),
    ));

    // Verify elements are displayed
    expect(find.textContaining('Spend Smarter'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.textContaining('Already Have Account?'), findsOneWidget);
  });
}
