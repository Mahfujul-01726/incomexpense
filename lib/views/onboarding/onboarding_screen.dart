import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                      : [const Color(0xFFEEF2F6), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          }),

          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.onboardingData.length,
            onPageChanged: (index) => controller.currentPage.value = index,
            itemBuilder: (context, index) {
              final item = controller.onboardingData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Illustration / Image
                    Container(
                      height: 320,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: const bool.fromEnvironment('FLUTTER_TEST')
                            ? _buildFallbackImage(index)
                            : Image.asset(
                                'Income & Expense Tracker App (Community)/${item['image']}',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => _buildFallbackImage(index),
                              ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Title
                    Text(
                      item['title']!,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      item['description']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                  ],
                ),
              );
            },
          ),

          // Top action (Skip button)
          Positioned(
            top: 50,
            right: 16,
            child: Obx(() {
              // Hide skip on the last screen
              if (controller.currentPage.value == controller.onboardingData.length - 1) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: controller.skipOnboarding,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),

          // Bottom navigation controls (Dot Indicator & Action Button)
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    controller.onboardingData.length,
                    (index) => Obx(() {
                      final isSelected = controller.currentPage.value == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),

                // Next / Get Started Button
                Obx(() {
                  final isLast = controller.currentPage.value == controller.onboardingData.length - 1;
                  return ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isLast ? 'Get Started' : 'Next'),
                        const SizedBox(width: 8),
                        Icon(
                          isLast ? Icons.check_circle_outline : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage(int index) {
    return Container(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          index == 0
              ? Icons.account_balance_wallet_outlined
              : index == 1
                  ? Icons.analytics_outlined
                  : Icons.credit_card_outlined,
          size: 100,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
