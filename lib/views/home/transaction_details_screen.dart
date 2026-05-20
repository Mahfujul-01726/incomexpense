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
    final isDark = Get.isDarkMode;
    final amountColor = isIncome ? const Color(0xFF2F7E79) : const Color(0xFFF44336);
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
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header with AppBar
            ClipPath(
              clipper: _DetailsHeaderClipper(),
              child: Container(
                height: 180,
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
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 24,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -60,
                      right: -40,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 28,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => _showDeleteConfirmation(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Receipt Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: amountColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: amountColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            color: amountColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          transaction.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : const Color(0xFF222222),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: amountColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: amountColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: List.generate(
                            25,
                            (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 2),
                                height: 1,
                                color: isDark
                                    ? Colors.white24
                                    : Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildDetailRow(
                            'Status', transaction.status.toUpperCase(),
                            valueColor: transaction.status == 'completed'
                                ? const Color(0xFF2F7E79)
                                : AppTheme.warningColor,
                            isBold: true),
                        const SizedBox(height: 18),
                        _buildDetailRow(
                            'Date',
                            DateFormat('MMMM d, yyyy')
                                .format(transaction.date)),
                        const SizedBox(height: 18),
                        _buildDetailRow(
                            'Time',
                            DateFormat('hh:mm a')
                                .format(transaction.date)),
                        const SizedBox(height: 18),
                        _buildDetailRow(
                            isIncome ? 'From' : 'To', transaction.payee),
                        const SizedBox(height: 18),
                        _buildDetailRow('Wallet/Account', wallet.name,
                            secondaryText: wallet.cardNumber),
                        const SizedBox(height: 18),
                        _buildDetailRow(
                            'Transaction ID',
                            'TXN-${transaction.id.length >= 8 ? transaction.id.substring(0, 8).toUpperCase() : transaction.id.toUpperCase().padRight(8, '0')}',
                            isCopyable: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (transaction.note.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
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
                  backgroundColor: const Color(0xFF2F7E79),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor,
      bool isBold = false,
      String? secondaryText,
      bool isCopyable = false}) {
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
                        color: valueColor ??
                            (isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.lightTextPrimary),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCopyable) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.copy_rounded,
                        size: 14, color: Color(0xFF2F7E79)),
                  ]
                ],
              ),
              if (secondaryText != null) ...[
                const SizedBox(height: 2),
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
              txController.deleteTransaction(transaction.id);
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

class _DetailsHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    final firstControlPoint = Offset(size.width / 2, size.height + 15);
    final firstEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
