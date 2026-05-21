import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_theme.dart';
import '../home/home_tab.dart';

class AppBottomNav extends StatelessWidget {
  final bool includeFabSpacer;

  const AppBottomNav({super.key, this.includeFabSpacer = true});

  @override
  Widget build(BuildContext context) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());
    final isDark = Get.isDarkMode;

    return BottomAppBar(
      elevation: 8,
      height: 64,
      padding: EdgeInsets.zero,
      color: isDark ? AppTheme.darkBg : Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, navController, 0, Icons.home_rounded, Icons.home_outlined),
          _buildNavItem(context, navController, 1, Icons.bar_chart_rounded, Icons.bar_chart_outlined),
          if (includeFabSpacer) const SizedBox(width: 48),
          _buildNavItem(context, navController, 2, Icons.credit_card_rounded, Icons.credit_card_outlined),
          _buildNavItem(context, navController, 3, Icons.person_rounded, Icons.person_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavigationController navController,
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
  ) {
    return Obx(() {
      final isSelected = navController.selectedIndex.value == index;
      final isDark = Get.isDarkMode;

      final activeColor = isDark ? AppTheme.secondaryColor : AppTheme.primaryColor;
      final inactiveColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFFC5C5C5);

      return GestureDetector(
        onTap: () {
          navController.changeTab(index);
          Get.offAllNamed('/dashboard');
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? activeColor : inactiveColor,
                size: 26,
              ),
            ],
          ),
        ),
      );
    });
  }
}
