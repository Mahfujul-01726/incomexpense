import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/transaction_model.dart';
import '../../models/wallet_model.dart';
import '../../theme/app_theme.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionModel transaction;
  final txController = Get.find<TransactionController>();
  final walletController = Get.find<WalletController>();

  TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final wallet = walletController.wallets.firstWhere(
      (w) => w.id == transaction.walletId,
      orElse: () => walletController.wallets.isNotEmpty
          ? walletController.wallets.first
          : WalletModel(
              id: 'unknown',
              name: 'Unknown Wallet',
              balance: 0,
              cardHolder: '',
              cardNumber: '****',
              expiryDate: '',
              type: 'cash',
              colorIndex: 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.expenseColor),
            onPressed: () => _showDeleteConfirmation(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Receipt Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Decorative top colored bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Category Icon
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor).withOpacity(0.1),
                          child: Icon(
                            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),

                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isIncome ? AppTheme.incomeColor : AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Amount
                        Text(
                          '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Receipt Details Divider
                        Row(
                          children: List.generate(
                            20,
                            (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                height: 1,
                                color: Get.isDarkMode ? Colors.white24 : Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Data fields
                        _buildDetailRow('Status', transaction.status.toUpperCase(), 
                          valueColor: transaction.status == 'completed' ? AppTheme.incomeColor : AppTheme.warningColor,
                          isBold: true
                        ),
                        const SizedBox(height: 18),
                        _buildDetailRow('Date', DateFormat('MMMM d, yyyy').format(transaction.date)),
                        const SizedBox(height: 18),
                        _buildDetailRow('Time', DateFormat('hh:mm a').format(transaction.date)),
                        const SizedBox(height: 18),
                        _buildDetailRow(isIncome ? 'From' : 'To', transaction.payee),
                        const SizedBox(height: 18),
                        _buildDetailRow('Wallet/Account', wallet.name, secondaryText: wallet.cardNumber),
                        const SizedBox(height: 18),
                        _buildDetailRow('Transaction ID', 'TXN-${transaction.id.substring(0, 8).toUpperCase()}', isCopyable: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note card
            if (transaction.note.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note / Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.note,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Action Button - Download Receipt
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Success',
                    'Receipt downloaded successfully to storage.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppTheme.incomeColor,
                    colorText: Colors.white,
                    margin: const EdgeInsets.all(16),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Download Receipt'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false, String? secondaryText, bool isCopyable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                        color: valueColor ?? (Get.isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCopyable) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.copy_rounded, size: 14, color: AppTheme.primaryColor),
                  ]
                ],
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 2),
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 11,
                    color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
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
        content: const Text('Are you sure you want to permanently delete this transaction? This will reverse the wallet balance adjustment.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              txController.deleteTransaction(transaction.id);
              Get.back(); // close dialog
              Get.back(); // return to home/stats
              Get.snackbar(
                'Deleted',
                'Transaction was deleted.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppTheme.expenseColor,
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.expenseColor)),
          ),
        ],
      ),
    );
  }
}
