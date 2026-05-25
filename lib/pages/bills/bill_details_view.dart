import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'bill_controller.dart';
import '../wallet/wallet_controller.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/calculations.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/payment_option_card.dart';
import '../../widgets/bill_logo_widget.dart';
import 'bill_payment_view.dart';

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

  void _payBill() {
    Get.to(() => BillPaymentScreen(
      bill: widget.bill,
      initialStep: 2,
      initialPaymentMethod: _paymentMethod,
      fromBillsScreen: true,
      fromDetailsScreen: true,
    ));
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
            top: 0, left: 0, right: 0,
            child: Container(
              height: 170 + statusBarHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                      onPressed: () => Get.back(),
                    ),
                  ),
                  const Text(
                    'Bill Details',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              child: Obx(() {
                final bill = billController.bills.firstWhere(
                  (b) => b.id == widget.bill.id,
                  orElse: () => widget.bill,
                );
                final price = bill.name.toLowerCase().contains('youtube') ? 11.99 : bill.amount;
                final fee = calculateFee(price);
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
                                  BillLogoWidget(name: bill.name, size: 64),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bill.name.toLowerCase().contains('youtube') ? 'Youtube Premium' : bill.name,
                                          style: TextStyle(
                                            fontSize: 17, fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(bill.dueDate),
                                          style: TextStyle(fontSize: 13, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            InvoiceRow(label: 'Price', value: formatter.format(price)),
                            InvoiceRow(label: 'Fee', value: formatter.format(fee)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                            ),
                            InvoiceRow(label: 'Total', value: formatter.format(total), isTotal: true),
                            const SizedBox(height: 24),
                            if (!bill.isPaid) ...[
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
                          width: double.infinity, height: 48,
                          child: ElevatedButton(
                            onPressed: _payBill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2F7E79),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
