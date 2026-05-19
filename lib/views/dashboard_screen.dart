import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home/home_tab.dart';
import 'statistics/statistics_tab.dart';
import 'wallet/wallet_tab.dart';
import 'profile/profile_tab.dart';
import 'add_transaction/add_transaction_screen.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _tabs = [
    HomeTab(),
    StatisticsTab(),
    WalletTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = navController.selectedIndex.value;
      final isDark = Get.isDarkMode;

      return Scaffold(
        body: IndexedStack(
          index: selected,
          children: _tabs,
        ),
        floatingActionButton: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.35),
                blurRadius: 15,
                offset: const Offset(0, 7),
              )
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => Get.to(() => const AddTransactionScreen()),
            backgroundColor: AppTheme.primaryColor,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          elevation: 8,
          height: 64,
          padding: EdgeInsets.zero,
          color: isDark ? AppTheme.darkBg : Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, Icons.home_outlined),
              _buildNavItem(context, 1, Icons.bar_chart_rounded, Icons.bar_chart_outlined),
              const SizedBox(width: 48), // Spacer for center FAB
              _buildNavItem(context, 2, Icons.credit_card_rounded, Icons.credit_card_outlined),
              _buildNavItem(context, 3, Icons.person_rounded, Icons.person_outline_rounded),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(BuildContext context, int index, IconData activeIcon, IconData inactiveIcon) {
    return Obx(() {
      final isSelected = navController.selectedIndex.value == index;
      final isDark = Get.isDarkMode;
      
      final activeColor = isDark ? AppTheme.secondaryColor : AppTheme.primaryColor;
      final inactiveColor = isDark ? AppTheme.darkTextSecondary : const Color(0xFFC5C5C5);

      return GestureDetector(
        onTap: () => navController.changeTab(index),
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
