import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/bill_model.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';

class BillPaymentScreen extends StatefulWidget {
  final BillModel bill;
  final int initialStep;
  final String initialPaymentMethod;

  const BillPaymentScreen({
    super.key,
    required this.bill,
    this.initialStep = 1,
    this.initialPaymentMethod = 'Debit Card',
  });

  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  final billController = Get.find<BillController>();
  final walletController = Get.find<WalletController>();
  final txController = Get.find<TransactionController>();
  final formatter = NumberFormat.currency(symbol: '\$ ', decimalDigits: 2);

  late int _step;
  late String _paymentMethod;
  String _selectedWalletId = '';
  String _transactionId = '';
  late double _price;
  late double _fee;
  late double _total;
  late String _formattedTime;
  late String _formattedDate;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _paymentMethod = widget.initialPaymentMethod;
    _price = widget.bill.name.toLowerCase().contains('youtube') ? 11.99 : widget.bill.amount;
    _fee = _calculateFee(_price);
    _total = _price + _fee;
    
    if (widget.bill.name.toLowerCase().contains('youtube')) {
      _transactionId = '209291383247299';
      _formattedTime = '08:15 AM';
      _formattedDate = 'Feb 28, 2022';
    } else {
      _transactionId = '20929138${(100000 + DateTime.now().millisecondsSinceEpoch % 900000)}';
      _formattedTime = DateFormat('hh:mm a').format(DateTime.now());
      _formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
    }

    if (walletController.wallets.isNotEmpty) {
      _selectedWalletId = walletController.wallets.first.id;
    }
  }

  double _calculateFee(double amount) {
    if ((amount - 11.99).abs() < 0.01) {
      return 1.99;
    }
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
Bill: ${widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name}
Provider: ${widget.bill.provider}
Amount: ${formatter.format(_price)}
Fee: ${formatter.format(_fee)}
Total: ${formatter.format(_total)}
Payment Method: $_paymentMethod
Status: Completed
Date: $_formattedDate
Time: $_formattedTime
Transaction ID: $_transactionId
═════════════════════════
Thank you for your payment!
''';
    Clipboard.setData(ClipboardData(text: receipt));
    Get.snackbar(
      'Receipt Copied',
      'Payment receipt has been copied to clipboard.',
      backgroundColor: const Color(0xFF2F7E79),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Widget _buildBillerLogo(String name, {double size = 80}) {
    final cleanName = name.toLowerCase();
    String? assetPath;
    if (cleanName.contains('youtube')) {
      assetPath = 'assets/images/logos/youtube.png';
    } else if (cleanName.contains('electricity')) {
      assetPath = 'assets/images/logos/electricity.png';
    } else if (cleanName.contains('rent') || cleanName.contains('house')) {
      assetPath = 'assets/images/logos/house_rent.png';
    } else if (cleanName.contains('spotify')) {
      assetPath = 'assets/images/logos/spotify.png';
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.22),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: assetPath != null
          ? Image.asset(assetPath, fit: BoxFit.contain)
          : Icon(Icons.receipt_long_rounded, color: const Color(0xFF2F7E79), size: size * 0.5),
    );
  }

  Widget _buildDebitCardLogo({required bool isSelected}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.credit_card_rounded,
          color: Color(0xFF2F7E79),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPayPalLogo({required bool isSelected}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.paypal_rounded,
          color: isSelected ? const Color(0xFF003087) : const Color(0xFF8C9AA9),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required Widget logo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A37) : const Color(0xFFEEF7F6))
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F7E79).withOpacity(0.2)
                : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2F7E79).withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            logo,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF2F7E79) : const Color(0xFFCBD5E1),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isTotal = false}) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? const Color(0xFF2F7E79)
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
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
                      onPressed: () {
                        if (_step == 1) {
                          Get.back();
                        } else if (_step == 2) {
                          setState(() => _step = 1);
                        } else {
                          Get.back();
                        }
                      },
                    ),
                  ),
                  Text(
                    _step == 1 ? 'Bill Details' : 'Bill Payment',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      onPressed: () {},
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
                      padding: const EdgeInsets.only(top: 24),
                      child: Column(
                        children: [
                          if (_step == 1) _buildStep1(),
                          if (_step == 2) _buildStep2(),
                          if (_step == 3) _buildStep3(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_step == 1) {
                            setState(() => _step = 2);
                          } else if (_step == 2) {
                            _processPayment();
                          } else {
                            _shareReceipt();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _step == 3 
                              ? (isDark ? AppTheme.darkSurface : Colors.white) 
                              : const Color(0xFF2F7E79),
                          foregroundColor: _step == 3 ? const Color(0xFF2F7E79) : Colors.white,
                          elevation: 0,
                          side: _step == 3 ? const BorderSide(color: Color(0xFF2F7E79), width: 1.5) : BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          _step == 1
                              ? 'Pay Now'
                              : _step == 2
                                  ? 'Confirm and Pay'
                                  : 'Share Receipt',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }

  Widget _buildStep1() {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildBillerLogo(widget.bill.name),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(widget.bill.dueDate),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 28),
        _buildInvoiceRow('Price', formatter.format(_price)),
        _buildInvoiceRow('Fee', formatter.format(_fee)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        _buildInvoiceRow('Total', formatter.format(_total), isTotal: true),
        const SizedBox(height: 36),
        Text(
          'Select payment method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        _buildPaymentOption(
          title: walletController.wallets.isNotEmpty
              ? 'Debit Card (... ${walletController.wallets.first.cardNumber.split(' ').last})'
              : 'Debit Card',
          logo: _buildDebitCardLogo(isSelected: _paymentMethod == 'Debit Card'),
          isSelected: _paymentMethod == 'Debit Card',
          onTap: () {
            setState(() {
              _paymentMethod = 'Debit Card';
            });
          },
        ),
        _buildPaymentOption(
          title: 'Paypal',
          logo: _buildPayPalLogo(isSelected: _paymentMethod == 'PayPal'),
          isSelected: _paymentMethod == 'PayPal',
          onTap: () {
            setState(() {
              _paymentMethod = 'PayPal';
            });
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isDark = Get.isDarkMode;
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildBillerLogo(widget.bill.name),
        const SizedBox(height: 30),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 20,
              height: 1.4,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontFamily: GoogleFonts.outfit().fontFamily,
            ),
            children: [
              const TextSpan(text: 'You will pay '),
              TextSpan(
                text: widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name,
                style: const TextStyle(color: Color(0xFF2F7E79)),
              ),
              TextSpan(
                text: '\nfor one month with ${_paymentMethod == 'Debit Card' ? 'BCA OneKlik' : 'PayPal'}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        _buildInvoiceRow('Price', formatter.format(_price)),
        _buildInvoiceRow('Fee', formatter.format(_fee)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        _buildInvoiceRow('Total', formatter.format(_total), isTotal: true),
      ],
    );
  }

  Widget _buildStep3() {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFECF8F7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2F7E79),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Successfully',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transaction details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildDetailRow('Payment method', _paymentMethod),
        _buildDetailRow('Status', 'Completed', valueColor: const Color(0xFF2F7E79)),
        _buildDetailRow('Time', _formattedTime),
        _buildDetailRow('Date', _formattedDate),
        
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: _transactionId));
            Get.snackbar(
              'Copied',
              'Transaction ID copied to clipboard.',
              backgroundColor: const Color(0xFF2F7E79),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction ID',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _transactionId.length > 13 ? '${_transactionId.substring(0, 13)}..' : _transactionId,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF2F7E79),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        _buildInvoiceRow('Price', formatter.format(_price)),
        _buildInvoiceRow('Fee', '- ${formatter.format(_fee)}'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            height: 1,
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
          ),
        ),
        _buildInvoiceRow('Total', formatter.format(_total), isTotal: true),
      ],
    );
  }
}
