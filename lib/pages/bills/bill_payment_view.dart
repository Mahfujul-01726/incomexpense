import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'bill_controller.dart';
import '../wallet/wallet_controller.dart';
import '../home/transaction_controller.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/calculations.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/payment_option_card.dart';
import '../../widgets/bill_logo_widget.dart';

class BillPaymentScreen extends StatefulWidget {
  final BillModel bill;
  final int initialStep;
  final String initialPaymentMethod;
  final bool fromBillsScreen;
  final bool fromDetailsScreen;

  const BillPaymentScreen({
    super.key,
    required this.bill,
    this.initialStep = 1,
    this.initialPaymentMethod = 'Debit Card',
    this.fromBillsScreen = false,
    this.fromDetailsScreen = false,
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
  var _showTransactionDetails = true;

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _paymentMethod = widget.initialPaymentMethod;
    _price = widget.bill.name.toLowerCase().contains('youtube') ? 11.99 : widget.bill.amount;
    _fee = calculateFee(_price);
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

  void _processPayment() {
    final walletId = _selectedWalletId.isNotEmpty
        ? _selectedWalletId
        : (walletController.wallets.isNotEmpty
            ? walletController.wallets.first.id
            : 'demo_wallet');

    billController.payBill(widget.bill.id, walletId, createTransaction: false);
    setState(() => _step = 3);
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
            top: 0, left: 0, right: 0,
            child: Container(
              height: 170 + statusBarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30, left: -30,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 24),
              ),
            ),
          ),
          Positioned(
            top: -50, right: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 28),
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight + 8, left: 16, right: 16,
            child: SizedBox(
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
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
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_rounded, color: Colors.white, size: 26),
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
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          if (_step == 1) _buildStep1(),
                          if (_step == 2) _buildStep2(),
                          if (_step == 3) _buildStep3(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity, height: 48,
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
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildStep1() {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BillLogoWidget(name: widget.bill.name, size: 64),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(widget.bill.dueDate),
                    style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InvoiceRow(label: 'Price', value: formatter.format(_price)),
        InvoiceRow(label: 'Fee', value: formatter.format(_fee)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        InvoiceRow(label: 'Total', value: formatter.format(_total), isTotal: true),
        const SizedBox(height: 24),
        Text(
          'Select payment method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
        PaymentOptionCard(
          title: walletController.wallets.isNotEmpty
              ? 'Debit Card (... ${walletController.wallets.first.cardNumber.split(' ').last})'
              : 'Debit Card',
          logo: const DebitCardLogo(),
          isSelected: _paymentMethod == 'Debit Card',
          onTap: () => setState(() => _paymentMethod = 'Debit Card'),
        ),
        PaymentOptionCard(
          title: 'Paypal',
          logo: const PayPalLogo(),
          isSelected: _paymentMethod == 'PayPal',
          onTap: () => setState(() => _paymentMethod = 'PayPal'),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isDark = Get.isDarkMode;
    return Column(
      children: [
        const SizedBox(height: 10),
        BillLogoWidget(name: widget.bill.name, size: 64),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 17, height: 1.3, fontWeight: FontWeight.bold,
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
        const SizedBox(height: 24),
        InvoiceRow(label: 'Price', value: formatter.format(_price)),
        InvoiceRow(label: 'Fee', value: formatter.format(_fee)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
        ),
        InvoiceRow(label: 'Total', value: formatter.format(_total), isTotal: true),
      ],
    );
  }

  Widget _buildStep3() {
    final isDark = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(color: Color(0xFFECF8F7), shape: BoxShape.circle),
                child: Center(
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF2F7E79), shape: BoxShape.circle),
                    child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 24)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successfully',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : widget.bill.name,
                style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _showTransactionDetails = !_showTransactionDetails),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
              ),
              Icon(
                _showTransactionDetails ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                size: 20,
              ),
            ],
          ),
        ),
        if (_showTransactionDetails) ...[
          const SizedBox(height: 10),
          TransactionDetailRow(label: 'Payment method', value: _paymentMethod),
          TransactionDetailRow(label: 'Status', value: 'Completed', valueColor: const Color(0xFF2F7E79)),
          TransactionDetailRow(label: 'Time', value: _formattedTime),
          TransactionDetailRow(label: 'Date', value: _formattedDate),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _transactionId));
              Get.snackbar('Copied', 'Transaction ID copied to clipboard.',
                  backgroundColor: const Color(0xFF2F7E79), colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction ID', style: TextStyle(fontSize: 14, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary, fontWeight: FontWeight.w500)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _transactionId.length > 13 ? '${_transactionId.substring(0, 13)}..' : _transactionId,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, color: Color(0xFF2F7E79), size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          InvoiceRow(label: 'Price', value: formatter.format(_price)),
          InvoiceRow(label: 'Fee', value: '- ${formatter.format(_fee)}'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          InvoiceRow(label: 'Total', value: formatter.format(_total), isTotal: true),
        ],
      ],
    );
  }
}
