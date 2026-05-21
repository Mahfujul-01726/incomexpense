import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final txController = Get.find<TransactionController>();
  var _showTransactionDetails = true;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isIncome = transaction.type == 'income';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isDark = Get.isDarkMode;
    final amountColor = isIncome ? const Color(0xFF2F7E79) : const Color(0xFFF44336);
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFCFCFC),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 170 + statusBarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 24,
                ),
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 28,
                ),
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + 8,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 130 + statusBarHeight,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          _buildLogo(transaction.title),
                          const SizedBox(height: 10),
                          Text(
                            transaction.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.darkTextPrimary
                                  : const Color(0xFF0F172A),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: amountColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              transaction.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: amountColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() => _showTransactionDetails = !_showTransactionDetails),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transaction details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Icon(
                            _showTransactionDetails
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    if (_showTransactionDetails) ...[
                      const SizedBox(height: 10),
                      _buildDetailRow(
                          'Status', transaction.status.toUpperCase(),
                          valueColor: transaction.status == 'completed'
                              ? const Color(0xFF2F7E79)
                              : AppTheme.warningColor),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          isIncome ? 'From' : 'To', transaction.payee),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          'Time',
                          DateFormat('hh:mm a')
                              .format(transaction.date)),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          'Date',
                          DateFormat('MMM d, yyyy')
                              .format(transaction.date)),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          'Spending',
                          '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                          valueColor: amountColor),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                          'Fee',
                          formatter.format(_calculateFee(transaction.amount))),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar(
                            'Success',
                            'Receipt downloaded successfully to storage.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2F7E79),
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.darkSurface
                              : Colors.white,
                          foregroundColor: const Color(0xFF2F7E79),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xFF2F7E79),
                            width: 1.5,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download_rounded, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Download Receipt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24 + bottomInset),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(includeFabSpacer: false),
    );
  }

  double _calculateFee(double amount) {
    if ((amount - 11.99).abs() < 0.01) return 1.99;
    final fee = amount * 0.029 + 0.30;
    return fee > 0.50 ? double.parse(fee.toStringAsFixed(2)) : 0.50;
  }

  Widget _buildLogo(String title) {
    String assetName = '';
    switch (title.toLowerCase()) {
      case 'upwork':
        assetName = 'logo_upwork.png';
        break;
      case 'transfer':
        assetName = 'profile_icon.png';
        break;
      case 'paypal':
        assetName = 'logo_paypal.png';
        break;
      case 'youtube':
        assetName = 'logo_youtube.png';
        break;
      case 'starbucks':
        assetName = 'logo_starbucks.png';
        break;
    }

    if (assetName.isNotEmpty) {
      final double pad = (assetName == 'logo_upwork.png' || assetName == 'profile_icon.png') ? 6 : 10;
      return Container(
        width: 56,
        height: 56,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          'assets/cropped/$assetName',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.payment_outlined,
            color: AppTheme.primaryColor.withOpacity(0.5),
            size: 24,
          ),
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        title.toLowerCase() == 'upwork' || widget.transaction.type == 'income'
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded,
        color: AppTheme.primaryColor,
        size: 24,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, String? secondaryText, bool isCopyable = false}) {
    final isDark = Get.isDarkMode;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: isCopyable
                    ? () {
                        Clipboard.setData(ClipboardData(text: value));
                        Get.snackbar(
                          'Copied',
                          'Transaction ID copied to clipboard.',
                          backgroundColor: const Color(0xFF2F7E79),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      }
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: valueColor ??
                              (isDark
                                  ? AppTheme.darkTextPrimary
                                  : const Color(0xFF0F172A)),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCopyable) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.copy_rounded,
                        color: Color(0xFF2F7E79),
                        size: 14,
                      ),
                    ]
                  ],
                ),
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 1),
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                )
              ]
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
            'Are you sure you want to permanently delete this transaction? This will reverse the wallet balance adjustment.'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              txController.deleteTransaction(widget.transaction.id);
              Get.back();
              Get.back();
              Get.snackbar(
                'Deleted',
                'Transaction was deleted.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.expenseColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}
