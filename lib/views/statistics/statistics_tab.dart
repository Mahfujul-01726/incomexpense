import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/transaction_controller.dart';
import '../../theme/app_theme.dart';
import '../home/transaction_details_screen.dart';

class StatisticsTab extends StatelessWidget {
  StatisticsTab({super.key});

  final txController = Get.find<TransactionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Period Filter (Week, Month, Year)
              _buildPeriodFilter(),
              const SizedBox(height: 24),

              // Income / Expense Toggle
              _buildTypeToggle(),
              const SizedBox(height: 24),

              // Chart Card
              _buildChartCard(context),
              const SizedBox(height: 28),

              // Top Categories Section
              Text(
                'Category Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Categories List with Progress Bars
              Obx(() {
                final breakdown = txController.categoryBreakdown;
                if (breakdown.isEmpty) {
                  return _buildNoDataState(context);
                }

                final total = breakdown.values.fold(0.0, (sum, val) => sum + val);

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: breakdown.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final category = breakdown.keys.elementAt(index);
                    final amount = breakdown[category]!;
                    final percentage = total > 0 ? (amount / total) * 100 : 0.0;

                    return _buildCategoryBreakdownItem(context, category, amount, percentage);
                  },
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = ['Week', 'Month', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.black.withOpacity(0.04),
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
                        ? (Get.isDarkMode ? AppTheme.primaryColor : Colors.white)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected && !Get.isDarkMode
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
                            ? (Get.isDarkMode ? Colors.white : AppTheme.primaryColor)
                            : (Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
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

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: Obx(() {
            final isSelected = txController.selectedType.value == 'income';
            return ElevatedButton(
              onPressed: () => txController.selectedType.value = 'income',
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppTheme.incomeColor : (Get.isDarkMode ? AppTheme.darkSurface : Colors.white),
                foregroundColor: isSelected ? Colors.white : (Get.isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                elevation: isSelected ? 4 : 0,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : (Get.isDarkMode ? Colors.white10 : Colors.black12),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_downward_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Income'),
                ],
              ),
            );
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() {
            final isSelected = txController.selectedType.value == 'expense';
            return ElevatedButton(
              onPressed: () => txController.selectedType.value = 'expense',
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppTheme.expenseColor : (Get.isDarkMode ? AppTheme.darkSurface : Colors.white),
                foregroundColor: isSelected ? Colors.white : (Get.isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                elevation: isSelected ? 4 : 0,
                side: BorderSide(
                  color: isSelected ? Colors.transparent : (Get.isDarkMode ? Colors.white10 : Colors.black12),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 18),
                  SizedBox(width: 6),
                  Text('Expenses'),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return Obx(() {
      final list = txController.filteredTransactions;
      final isDark = Get.isDarkMode;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Analysis',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '\$').format(
                        list.fold(0.0, (sum, item) => sum + item.amount),
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.show_chart_rounded, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: list.isEmpty
                  ? const Center(child: Text('Add transactions to view the analysis chart.'))
                  : LineChart(
                      _getLineChartData(list),
                    ),
            ),
          ],
        ),
      );
    });
  }

  LineChartData _getLineChartData(List<dynamic> list) {
    // Sort transactions by date
    final sorted = List.from(list)..sort((a, b) => a.date.compareTo(b.date));
    
    // Group transactions by day/date for Line Chart points
    final Map<String, double> grouped = {};
    for (var tx in sorted) {
      final key = DateFormat('MM-dd').format(tx.date);
      grouped[key] = (grouped[key] ?? 0.0) + tx.amount;
    }

    final spots = <FlSpot>[];
    final keys = grouped.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), grouped[keys[i]]!));
    }

    // fallback if only 1 data point to avoid crash
    if (spots.length == 1) {
      spots.insert(0, FlSpot(0, spots[0].y));
    }

    final isIncome = txController.selectedType.value == 'income';
    final themeColor = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < keys.length) {
                // Show alternate titles to prevent crowding
                if (keys.length > 5 && index % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    keys[index],
                    style: TextStyle(
                      color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
          spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
          isCurved: true,
          color: themeColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length < 10,
            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
              radius: 4,
              color: themeColor,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                themeColor.withOpacity(0.3),
                themeColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdownItem(BuildContext context, String category, double amount, double percentage) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isIncome = txController.selectedType.value == 'income';
    final color = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 12,
                    width: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
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
