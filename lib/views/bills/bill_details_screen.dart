import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/bill_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import 'bill_payment_screen.dart';

class BillDetailsScreen extends StatefulWidget {
  final BillModel bill;

  const BillDetailsScreen({super.key, required this.bill});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final billController = Get.find<BillController>();
  final walletController = Get.find<WalletController>();
  String _paymentMethod = 'Debit Card';

  @override
  void initState() {
    super.initState();
  }

  double _calculateFee(double amount) {
    if ((amount - 11.99).abs() < 0.01) {
      return 1.99;
    }
    final fee = amount * 0.029 + 0.30;
    return fee > 0.50 ? double.parse(fee.toStringAsFixed(2)) : 0.50;
  }

  void _payBill() {
    Get.to(() => BillPaymentScreen(
          bill: widget.bill,
          initialStep: 2,
          initialPaymentMethod: _paymentMethod,
          fromBillsScreen: true,
          fromDetailsScreen: true,
        ));
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
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A37) : const Color(0xFFEEF7F6))
              : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F7E79).withValues(alpha: 0.2)
                : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2F7E79).withValues(alpha: 0.04),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF2F7E79) : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isTotal = false}) {
    final isDark = Get.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final formatter = NumberFormat.currency(symbol: '\$ ', decimalDigits: 2);
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
                  color: Colors.white.withValues(alpha: 0.08),
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
                  color: Colors.white.withValues(alpha: 0.08),
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
                    'Bill Details',
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
              child: Obx(() {
                final bill = billController.bills.firstWhere(
                  (b) => b.id == widget.bill.id,
                  orElse: () => widget.bill,
                );

                final price = bill.name.toLowerCase().contains('youtube') ? 11.99 : bill.amount;
                final fee = _calculateFee(price);
                final total = price + fee;

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Row(
                                children: [
                                  _buildBillerLogo(bill.name, size: 64),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : bill.name,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(bill.dueDate),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            _buildInvoiceRow('Price', formatter.format(price)),
                            _buildInvoiceRow('Fee', formatter.format(fee)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                height: 1,
                                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            _buildInvoiceRow('Total', formatter.format(total), isTotal: true),

                            const SizedBox(height: 24),

                            if (!bill.isPaid) ...[
                              Text(
                                'Select payment method',
                                style: TextStyle(
                                  fontSize: 16,
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
                            ] else ...[
                              Container(
                                padding: const EdgeInsets.all(20),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppTheme.incomeColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.incomeColor.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: AppTheme.incomeColor, size: 24),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Bill paid successfully.',
                                      style: TextStyle(
                                        color: AppTheme.incomeColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        fontFamily: GoogleFonts.outfit().fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (!bill.isPaid) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20, top: 12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _payBill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F7E79),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Pay Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: bottomInset),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(includeFabSpacer: false),
    );
  }
}

