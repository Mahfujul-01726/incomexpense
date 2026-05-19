import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';

class BillDetailsScreen extends StatefulWidget {
  final BillModel bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final billController = Get.find<BillController>();
  final walletController = Get.find<WalletController>();
  String _selectedWalletId = '';

  @override
  void initState() {
    super.initState();
    if (walletController.wallets.isNotEmpty) {
      _selectedWalletId = walletController.wallets.first.id;
    }
  }

  void _payBill() {
    if (_selectedWalletId.isEmpty) {
      Get.snackbar('Error', 'Please select a wallet or card to pay from.',
          backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    final success = billController.payBill(widget.bill.id, _selectedWalletId);
    if (success) {
      Get.back(); // close details page
      _showSuccessDialog();
    } else {
      Get.snackbar('Error', 'This bill is already paid.',
          backgroundColor: AppTheme.warningColor, colorText: Colors.white);
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.incomeColor,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your payment for ${widget.bill.name} has been processed successfully.',
                style: TextStyle(
                  fontSize: 14,
                  color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Bills'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final now = DateTime.now();
    final difference = widget.bill.dueDate.difference(now).inDays;

    Color statusColor;
    String statusText;
    if (widget.bill.isPaid) {
      statusColor = AppTheme.incomeColor;
      statusText = 'Paid';
    } else if (difference < 0) {
      statusColor = AppTheme.expenseColor;
      statusText = 'Overdue by ${difference.abs()} days';
    } else {
      statusColor = AppTheme.warningColor;
      statusText = 'Pending Payment';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Bill Invoice Layout
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Biller Logo simulation
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: statusColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.bill.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.bill.provider,
                          style: TextStyle(
                            fontSize: 13,
                            color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Amount Due
                        Text(
                          formatter.format(widget.bill.amount),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Get.isDarkMode ? Colors.white : AppTheme.lightTextPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 32),
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
                        // Invoice details
                        _buildInvoiceDetailRow('Payment Status', statusText, valueColor: statusColor),
                        const SizedBox(height: 16),
                        _buildInvoiceDetailRow('Due Date', DateFormat('MMMM dd, yyyy').format(widget.bill.dueDate)),
                        const SizedBox(height: 16),
                        _buildInvoiceDetailRow('Category', widget.bill.category),
                        const SizedBox(height: 16),
                        // Auto Pay switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Auto-Pay enabled',
                              style: TextStyle(
                                fontSize: 14,
                                color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                            Switch(
                              value: widget.bill.autoPay,
                              activeColor: AppTheme.primaryColor,
                              onChanged: (val) {
                                billController.toggleAutoPay(widget.bill.id);
                                setState(() {});
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pay card selection (if unpaid)
            if (!widget.bill.isPaid) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay From Wallet/Card',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final wallets = walletController.wallets;
                      if (wallets.isEmpty) {
                        return const Text('No wallets or cards linked.');
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedWalletId.isNotEmpty ? _selectedWalletId : null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.credit_card_rounded),
                        ),
                        items: wallets.map((w) {
                          return DropdownMenuItem<String>(
                            value: w.id,
                            child: Text('${w.name} (\$...${w.cardNumber.split(' ').last})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _selectedWalletId = val;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action button to pay
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _payBill,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Pay ${formatter.format(widget.bill.amount)} Now'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.incomeColor.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: AppTheme.incomeColor),
                    SizedBox(width: 12),
                    Text(
                      'Bill paid successfully.',
                      style: TextStyle(
                        color: AppTheme.incomeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (Get.isDarkMode ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
