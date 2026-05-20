import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/bill_model.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class BillPaymentScreen extends StatefulWidget {
  final BillModel bill;

  const BillPaymentScreen({super.key, required this.bill});

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final billController = Get.find<BillController>();
  final walletController = Get.find<WalletController>();
  final txController = Get.find<TransactionController>();
  final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  int _step = 1;
  String _paymentMethod = 'Debit Card';
  String _selectedWalletId = '';
  String _transactionId = '';
  late double _fee;
  late double _total;

  @override
  void initState() {
    super.initState();
    _fee = _calculateFee(widget.bill.amount);
    _total = widget.bill.amount + _fee;
    _transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}${const Uuid().v4().substring(0, 4).toUpperCase()}';
    if (walletController.wallets.isNotEmpty) {
      _selectedWalletId = walletController.wallets.first.id;
    }
  }

  double _calculateFee(double amount) {
    final fee = amount * 0.029 + 0.30;
    return fee > 0.50 ? double.parse(fee.toStringAsFixed(2)) : 0.50;
  }

  void _processPayment() {
    if (_selectedWalletId.isEmpty) {
      Get.snackbar('Error', 'No wallet found. Please add a wallet first.',
          backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    final wallet = walletController.wallets.firstWhereOrNull((w) => w.id == _selectedWalletId);
    if (wallet == null || wallet.balance < _total) {
      Get.snackbar('Insufficient Balance',
          'Your selected wallet does not have enough balance to complete this payment.',
          backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
      return;
    }

    walletController.updateWalletBalance(_selectedWalletId, widget.bill.amount, 'expense');

    billController.payBill(widget.bill.id, _selectedWalletId);

    final newTx = TransactionModel(
      id: _transactionId,
      title: 'Paid: ${widget.bill.name}',
      amount: widget.bill.amount,
      type: 'expense',
      category: widget.bill.category,
      date: DateTime.now(),
      walletId: _selectedWalletId,
      payee: widget.bill.provider,
      note: 'Payment via $_paymentMethod. Fee: ${formatter.format(_fee)}',
      status: 'completed',
    );
    txController.addTransaction(newTx);

    setState(() {
      _step = 3;
    });
  }

  void _shareReceipt() {
    final receipt = '''
PAYMENT RECEIPT
═════════════════════════
Bill: ${widget.bill.name}
Provider: ${widget.bill.provider}
Amount: ${formatter.format(widget.bill.amount)}
Fee: ${formatter.format(_fee)}
Total: ${formatter.format(_total)}
Payment Method: $_paymentMethod
Status: Completed
Date: ${DateFormat('MMMM dd, yyyy – hh:mm a').format(DateTime.now())}
Transaction ID: $_transactionId
═════════════════════════
Thank you for your payment!
''';
    Clipboard.setData(ClipboardData(text: receipt));
    Get.snackbar(
      'Receipt Copied',
      'Payment receipt has been copied to clipboard.',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_step == 1 ? 'Bill Details' : _step == 2 ? 'Confirm Payment' : 'Payment Receipt'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            if (_step == 1) {
              Get.back();
            } else {
              setState(() => _step--);
            }
          },
        ),
        actions: [
          if (_step == 3)
            IconButton(
              icon: const Icon(Icons.share_rounded, size: 22),
              onPressed: _shareReceipt,
              tooltip: 'Share Receipt',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_step == 1) _buildStep1(isDark),
              if (_step == 2) _buildStep2(isDark),
              if (_step == 3) _buildStep3(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP 1: Bill Details & Payment Method ──────────────────────────
  Widget _buildStep1(bool isDark) {
    return Column(
      children: [
        _buildBillHeader(isDark),
        const SizedBox(height: 24),
        _buildPriceFeeCard(isDark),
        const SizedBox(height: 24),
        _buildPaymentMethodSection(isDark),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedWalletId.isEmpty) {
                Get.snackbar('Error', 'No wallet selected.',
                    backgroundColor: AppTheme.expenseColor, colorText: Colors.white);
                return;
              }
              setState(() => _step = 2);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Pay ${formatter.format(widget.bill.amount)} Now'),
          ),
        ),
      ],
    );
  }

  Widget _buildBillHeader(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              widget.bill.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF222222)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              widget.bill.provider,
              style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFeeCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildRow('Price', formatter.format(widget.bill.amount)),
          const SizedBox(height: 14),
          _buildRow('Fee', formatter.format(_fee)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
          _buildRow('Total', formatter.format(_total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppTheme.primaryColor : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            isDark: isDark,
            icon: Icons.credit_card_rounded,
            title: 'Debit Card',
            subtitle: 'Pay with your debit card',
            isSelected: _paymentMethod == 'Debit Card',
            onTap: () => setState(() => _paymentMethod = 'Debit Card'),
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            isDark: isDark,
            icon: Icons.paypal_rounded,
            title: 'PayPal',
            subtitle: 'Pay with your PayPal account',
            isSelected: _paymentMethod == 'PayPal',
            onTap: () => setState(() => _paymentMethod = 'PayPal'),
          ),
          const SizedBox(height: 16),
          Text(
            'Pay From Wallet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final wallets = walletController.wallets;
            if (wallets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No wallets available.',
                    style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
              );
            }
            return DropdownButtonFormField<String>(
              value: _selectedWalletId.isNotEmpty ? _selectedWalletId : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppTheme.darkBg : const Color(0xFFF1F5F9),
                prefixIcon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
              ),
              dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
              items: wallets.map((w) {
                return DropdownMenuItem<String>(
                  value: w.id,
                  child: Text('${w.name} (${formatter.format(w.balance)})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedWalletId = val);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.08)
              : (isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white60 : Colors.black54), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected ? AppTheme.primaryColor : (isDark ? Colors.white : const Color(0xFF222222)),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── STEP 2: Confirm Payment ────────────────────────────────────────
  Widget _buildStep2(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                child: const Icon(Icons.receipt_long_rounded, color: AppTheme.warningColor, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'You will pay for',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.bill.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF222222),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.bill.provider,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: List.generate(
                  20,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 1,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildRow('Price', formatter.format(widget.bill.amount)),
              const SizedBox(height: 14),
              _buildRow('Fee', formatter.format(_fee)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),
              _buildRow('Total', formatter.format(_total), isTotal: true),
              const SizedBox(height: 8),
              _buildRow('Payment Method', _paymentMethod),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Confirm and Pay'),
          ),
        ),
      ],
    );
  }

  // ─── STEP 3: Payment Successful ─────────────────────────────────────
  Widget _buildStep3(bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
              const SizedBox(height: 20),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Your payment for ${widget.bill.name} has been processed.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: List.generate(
                  20,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 1,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Payment Method', _paymentMethod, isDark),
              const SizedBox(height: 14),
              _buildDetailRow('Status', 'Completed', isDark, valueColor: AppTheme.incomeColor),
              const SizedBox(height: 14),
              _buildDetailRow('Date & Time', DateFormat('MMMM dd, yyyy – hh:mm a').format(DateTime.now()), isDark),
              const SizedBox(height: 14),
              _buildDetailRow('Transaction ID', _transactionId, isDark),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              _buildDetailRow('Price', formatter.format(widget.bill.amount), isDark),
              const SizedBox(height: 14),
              _buildDetailRow('Fee', formatter.format(_fee), isDark),
              const SizedBox(height: 14),
              _buildDetailRow('Total', formatter.format(_total), isDark, valueColor: AppTheme.primaryColor, isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareReceipt,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share Receipt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Back to Bills'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
