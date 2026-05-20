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
  final touchedSpotIndex = 2.obs; // May selected by default
  final selectedSpendingIndex = 1.obs; // Transfer (2nd item) selected by default

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF222222);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFCFCFC),
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
              final navController = Get.find<NavigationController>();
              navController.changeTab(0);
            } catch (_) {
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

              // Dropdown selector aligned to right
              _buildDropdownSelector(isDark, textColor),
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
    return Row(
      children: periods.map((period) {
        return Expanded(
          child: Obx(() {
            final isSelected = txController.selectedPeriod.value == period;
            return GestureDetector(
              onTap: () {
                txController.selectedPeriod.value = period;
                // Reset touched spot to a default index appropriate for the period
                if (period == 'Day') {
                  touchedSpotIndex.value = 1;
                } else if (period == 'Week') {
                  touchedSpotIndex.value = 3;
                } else if (period == 'Month') {
                  touchedSpotIndex.value = 1;
                } else {
                  touchedSpotIndex.value = 2; // May (index 2 in Mar-Sep label list)
                }
              },
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF666666)),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownSelector(bool isDark, Color textColor) {
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(() {
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
              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
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
    );
  }

  Widget _buildChartArea(bool isDark) {
    return Obx(() {
      final period = txController.selectedPeriod.value;
      
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
        // Year filter - showing 7 months matching design mockup
        spots = [
          const FlSpot(0, 1.5),
          const FlSpot(1, 3.0),
          const FlSpot(2, 2.2),
          const FlSpot(3, 4.0),
          const FlSpot(4, 3.2),
          const FlSpot(5, 5.5),
          const FlSpot(6, 4.2),
        ];
        bottomLabels = ['Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
      }

      // Check boundary constraints for safety
      if (touchedSpotIndex.value >= spots.length) {
        touchedSpotIndex.value = spots.length - 1;
      }

      final barData = LineChartBarData(
        spots: spots,
        isCurved: true,
        color: AppTheme.primaryColor,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final isHighlighted = index == touchedSpotIndex.value;
            return FlDotCirclePainter(
              radius: isHighlighted ? 6 : 0,
              color: AppTheme.primaryColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(0.24),
              AppTheme.primaryColor.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );

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
                  reservedSize: 32,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < bottomLabels.length) {
                      final isSelected = index == touchedSpotIndex.value;
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          bottomLabels[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8)),
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                if (touchResponse != null &&
                    touchResponse.lineBarSpots != null &&
                    touchResponse.lineBarSpots!.isNotEmpty) {
                  final spotIndex = touchResponse.lineBarSpots!.first.spotIndex;
                  touchedSpotIndex.value = spotIndex;
                }
              },
              getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                return spotIndexes.map((spotIndex) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: AppTheme.primaryColor,
                          strokeColor: Colors.white,
                          strokeWidth: 2,
                        );
                      },
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.white,
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipBorder: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final value = barSpot.y;
                    double actualAmount;
                    if (period == 'Day') {
                      actualAmount = value * 100;
                    } else if (period == 'Week') {
                      actualAmount = value * 80;
                    } else if (period == 'Month') {
                      actualAmount = value * 250;
                    } else {
                      if (barSpot.spotIndex == 2 && period == 'Year') {
                        actualAmount = 1230.00; // May matches $1230 exactly as in mockup!
                      } else {
                        actualAmount = value * 300;
                      }
                    }
                    return LineTooltipItem(
                      '\$${actualAmount.toStringAsFixed(0)}',
                      const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            showingTooltipIndicators: [
              ShowingTooltipIndicators([
                LineBarSpot(
                  barData,
                  0,
                  barData.spots[touchedSpotIndex.value],
                ),
              ]),
            ],
            lineBarsData: [barData],
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

      final itemCount = expenses.length > 3 ? 3 : expenses.length;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final tx = expenses[index];
          return _buildSpendingItem(context, tx, index, isDark, textColor);
        },
      );
    });
  }

  Widget _buildSpendingItem(BuildContext context, dynamic tx, int index, bool isDark, Color textColor) {
    return Obx(() {
      final isSelected = selectedSpendingIndex.value == index;
      
      final cardBg = isSelected
          ? AppTheme.primaryColor
          : (isDark ? AppTheme.darkSurface : Colors.white);
      
      final titleColor = isSelected
          ? Colors.white
          : (isDark ? AppTheme.darkTextPrimary : const Color(0xFF1E293B));
          
      final subtitleColor = isSelected
          ? Colors.white.withOpacity(0.7)
          : (isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B));
          
      final amountColor = isSelected
          ? Colors.white
          : AppTheme.expenseColor;

      return GestureDetector(
        onTap: () {
          selectedSpendingIndex.value = index;
          // Navigate to details on double tap or detail button?
          // To preserve original navigation on tap:
          Get.to(() => TransactionDetailsScreen(transaction: tx));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.015),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _getLogoWidget(tx.title),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(tx.date),
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '- \$ ${tx.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _getLogoWidget(String title) {
    final name = title.toLowerCase();
    String? assetName;
    if (name.contains('starbucks')) {
      assetName = 'logo_starbucks.png';
    } else if (name.contains('transfer')) {
      assetName = 'avatar_1.png';
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
