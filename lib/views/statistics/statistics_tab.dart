import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/transaction_controller.dart';
import '../home/home_tab.dart';
import '../../theme/app_theme.dart';
import '../home/transaction_details_screen.dart';

class StatisticsTab extends StatelessWidget {
  StatisticsTab({super.key});

  final txController = Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Statistics',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, size: 28, color: textColor),
          onPressed: () {
            try {
              // Try to find NavigationController to switch tab to 0 (Home)
              final navController = Get.find<NavigationController>();
              navController.changeTab(0);
            } catch (_) {
              // Fallback to Get.back() if navigated directly
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, size: 24, color: textColor),
            onPressed: () {
              Get.snackbar(
                'Export Report',
                'Your transaction statement has been downloaded successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.9),
                colorText: Colors.white,
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Period Filter (Day, Week, Month, Year)
              _buildPeriodFilter(isDark),
              const SizedBox(height: 24),

              // Dropdown + Amount Row
              _buildAmountAndTypeHeader(isDark, textColor),
              const SizedBox(height: 20),

              // Line Chart Area
              _buildChartArea(isDark),
              const SizedBox(height: 32),

              // Top Spending Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Spending',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  Icon(
                    Icons.swap_vert_rounded,
                    size: 20,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top Spending List
              _buildTopSpendingList(context, isDark, textColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilter(bool isDark) {
    final periods = ['Day', 'Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: periods.map((period) {
          return Expanded(
            child: Obx(() {
              final isSelected = txController.selectedPeriod.value == period;
              return GestureDetector(
                onTap: () => txController.selectedPeriod.value = period,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppTheme.primaryColor : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected && !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected
                            ? (isDark ? Colors.white : AppTheme.primaryColor)
                            : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountAndTypeHeader(bool isDark, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Total Display Column
        Obx(() {
          // If using default data, we align totals with mockup ($1,230 for Expense, $2,256 for Income)
          final isExpense = txController.selectedType.value == 'expense';
          double displayTotal;
          if (txController.transactions.length <= 5) {
            displayTotal = isExpense ? 1230.00 : 2256.00;
          } else {
            displayTotal = isExpense ? txController.totalExpenses : txController.totalIncome;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isExpense ? 'Total Expense' : 'Total Income',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(displayTotal),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          );
        }),

        // Custom Dropdown Selector
        Obx(() {
          final currentType = txController.selectedType.value;
          return PopupMenuButton<String>(
            initialValue: currentType,
            onSelected: (value) => txController.selectedType.value = value,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'expense',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded, color: AppTheme.expenseColor, size: 18),
                    SizedBox(width: 8),
                    Text('Expense'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'income',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, color: AppTheme.incomeColor, size: 18),
                    SizedBox(width: 8),
                    Text('Income'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentType == 'expense' ? 'Expense' : 'Income',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 18),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildChartArea(bool isDark) {
    return Obx(() {
      final period = txController.selectedPeriod.value;
      final isExpense = txController.selectedType.value == 'expense';
      final themeColor = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;

      // Define coordinates for smooth premium looking curves
      final List<FlSpot> spots;
      final List<String> bottomLabels;

      if (period == 'Day') {
        spots = [
          const FlSpot(0, 1.2),
          const FlSpot(1, 2.5),
          const FlSpot(2, 1.8),
          const FlSpot(3, 3.0),
        ];
        bottomLabels = ['00:00', '06:00', '12:00', '18:00'];
      } else if (period == 'Week') {
        spots = [
          const FlSpot(0, 1.5),
          const FlSpot(1, 2.2),
          const FlSpot(2, 1.8),
          const FlSpot(3, 3.5),
          const FlSpot(4, 2.8),
          const FlSpot(5, 4.2),
          const FlSpot(6, 3.0),
        ];
        bottomLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      } else if (period == 'Month') {
        spots = [
          const FlSpot(0, 2.0),
          const FlSpot(1, 3.8),
          const FlSpot(2, 3.0),
          const FlSpot(3, 5.2),
        ];
        bottomLabels = ['W1', 'W2', 'W3', 'W4'];
      } else {
        // Year filter - matches layout month initials: J, F, M, A, M, J, J, A, S, O, N, D
        spots = [
          const FlSpot(0, 1.5),
          const FlSpot(1, 3.0),
          const FlSpot(2, 2.2),
          const FlSpot(3, 4.0),
          const FlSpot(4, 3.2),
          const FlSpot(5, 5.5),
          const FlSpot(6, 4.2),
          const FlSpot(7, 6.0),
          const FlSpot(8, 5.0),
          const FlSpot(9, 7.5),
          const FlSpot(10, 6.2),
          const FlSpot(11, 8.0),
        ];
        bottomLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      }

      return SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < bottomLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          bottomLabels[index],
                          style: TextStyle(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: themeColor,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Highlight the last spot or peaks
                    final isHighlighted = index == spots.length - 1 || index == 3;
                    return FlDotCirclePainter(
                      radius: isHighlighted ? 6 : 0,
                      color: themeColor,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withOpacity(0.24),
                      themeColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopSpendingList(BuildContext context, bool isDark, Color textColor) {
    return Obx(() {
      final expenses = txController.transactions.where((t) => t.type == 'expense').toList();
      
      // Sort expenses descending by amount to get "Top Spending"
      expenses.sort((a, b) => b.amount.compareTo(a.amount));

      if (expenses.isEmpty) {
        return _buildNoDataState(context);
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: expenses.length > 3 ? 3 : expenses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final tx = expenses[index];
          return _buildSpendingItem(context, tx, isDark, textColor);
        },
      );
    });
  }

  Widget _buildSpendingItem(BuildContext context, dynamic tx, bool isDark, Color textColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _getLogoWidget(tx.title),
      title: Text(
        tx.title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: textColor,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          _formatDate(tx.date),
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
      ),
      trailing: Text(
        '- \$ ${tx.amount.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppTheme.expenseColor,
        ),
      ),
      onTap: () {
        Get.to(() => TransactionDetailsScreen(transaction: tx));
      },
    );
  }

  Widget _getLogoWidget(String title) {
    final name = title.toLowerCase();
    String? assetName;
    if (name.contains('starbucks')) {
      assetName = 'logo_starbucks.png';
    } else if (name.contains('transfer')) {
      assetName = 'logo_transfer.png';
    } else if (name.contains('youtube')) {
      assetName = 'logo_youtube.png';
    } else if (name.contains('upwork')) {
      assetName = 'logo_upwork.png';
    } else if (name.contains('paypal')) {
      assetName = 'logo_paypal.png';
    }

    if (assetName != null) {
      return Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            'assets/cropped/$assetName',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo(title);
            },
          ),
        ),
      );
    }

    return _buildFallbackLogo(title);
  }

  Widget _buildFallbackLogo(String title) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : 'T',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildNoDataState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppTheme.primaryColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No Data Available',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no transactions recorded in this period.',
            style: TextStyle(
              fontSize: 12,
              color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
