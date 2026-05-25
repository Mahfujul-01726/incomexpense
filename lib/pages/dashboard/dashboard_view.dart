import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'navigation_controller.dart';
import '../home/home_tab.dart';
import '../statistics/statistics_tab.dart';
import '../wallet/wallet_tab.dart';
import '../profile/profile_tab.dart';
import '../add_transaction/add_transaction_view.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final NavigationController navController = Get.find<NavigationController>();

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
                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
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
        bottomNavigationBar: const AppBottomNav(),
      );
    });
  }
}
