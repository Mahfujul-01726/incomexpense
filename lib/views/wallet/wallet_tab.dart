import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../home/transaction_details_screen.dart';
import '../home/home_tab.dart';
import '../bills/bill_payment_screen.dart';
import 'connect_wallet_screen.dart';
import 'qr_scanner_screen.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final walletController = Get.find<WalletController>();
  final txController = Get.find<TransactionController>();
  final billController = Get.find<BillController>();

  int _selectedTab = 0; // 0 = Transactions, 1 = Upcoming Bills

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Curved Teal Header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Invisible spacer to make Stack tall enough for hit testing
                const SizedBox(height: 360),
                // Wave background
                ClipPath(
                  clipper: WalletHeaderWaveClipper(),
                  child: Container(
                    height: 240,
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
                        // Decorative rings
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
                          top: -60,
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
                        // Inner Content Header Row
                        Padding(
                          padding: EdgeInsets.only(
                            top: statusBarHeight + 12,
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () {
                                  try {
                                    Get.find<NavigationController>().changeTab(0);
                                  } catch (_) {
                                    Get.back();
                                  }
                                },
                              ),
                              // Wallet title
                              const Text(
                                'Wallet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Notification Icon inside translucent box
                              GestureDetector(
                                onTap: () {
                                  Get.snackbar(
                                    'Notifications',
                                    'No new notifications.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(16),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(
                                        Icons.notifications_none_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      // Notification orange dot
                                      Positioned(
                                        top: 10,
                                        right: 11,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: Colors.orangeAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Card overlapping the bottom of wavy header
                Positioned(
                  top: 130,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Balance Section
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white60 : const Color(0xFF666666),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final balanceStr = NumberFormat('#,##0.00').format(walletController.totalBalance);
                          return Text(
                            '\$ $balanceStr',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF222222),
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        // Quick Action Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              context,
                              icon: Icons.add,
                              label: 'Add',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConnectWalletScreen(
                                      onBack: () => Navigator.pop(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.qr_code_scanner_rounded,
                              label: 'Pay',
                              onTap: () => _showPaySimulator(context),
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.send_rounded,
                              label: 'Send',
                              onTap: () => _showSendSimulator(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Sliding Tab/Segmented Control
            _buildTabSelector(isDark),
            const SizedBox(height: 16),

            // Tab Content List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _selectedTab == 0
                  ? _buildTransactionsList(isDark)
                  : _buildUpcomingBillsList(isDark),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBg : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2F7E79).withOpacity(isDark ? 0.3 : 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2F7E79),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(0, 'Transactions', isDark),
          ),
          Expanded(
            child: _buildTabButton(1, 'Upcoming Bills', isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label, bool isDark) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.darkBg : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF222222))
                : (isDark ? Colors.white60 : const Color(0xFF666666)),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(bool isDark) {
    return Obx(() {
      final transactions = txController.transactions.toList();

      if (transactions.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Text(
            'No transactions logged.',
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        );
      }

      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isIncome = tx.type == 'income';
          final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
          final color = isIncome ? const Color(0xFF2F7E79) : const Color(0xFFF44336);
          final sign = isIncome ? '+' : '-';

          // Format relative date (Today, Yesterday, or date string)
          String dateStr;
          final now = DateTime.now();
          final diff = now.difference(tx.date).inDays;
          if (diff == 0 && now.day == tx.date.day) {
            dateStr = 'Today';
          } else if (diff == 1 || (diff == 0 && now.day - 1 == tx.date.day)) {
            dateStr = 'Yesterday';
          } else {
            dateStr = DateFormat('MMM d, yyyy').format(tx.date);
          }

          return GestureDetector(
            onTap: () => Get.to(() => TransactionDetailsScreen(transaction: tx)),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildTransactionIcon(tx.title, isIncome),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$sign ${formatter.format(tx.amount).replaceAll('\$', '')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildUpcomingBillsList(bool isDark) {
    return Obx(() {
      final bills = billController.bills.where((b) => !b.isPaid).toList();

      if (bills.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Text(
            'All bills paid! You are all set.',
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF666666),
              fontSize: 14,
            ),
          ),
        );
      }

      // Sort by due date ascending
      bills.sort((a, b) => a.dueDate.compareTo(b.dueDate));

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bill = bills[index];
          final dateStr = DateFormat('MMM d, yyyy').format(bill.dueDate);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.1 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBillIcon(bill.name),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bill.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF222222),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : const Color(0xFF888888),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Get.to(() => BillPaymentScreen(bill: bill)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F7E79).withOpacity(isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Pay',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF2F7E79),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTransactionIcon(String title, bool isIncome) {
    final cleanTitle = title.toLowerCase();

    Widget buildGlassContainer({required Widget child, bool isIncome = false}) {
      final accentColor = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;
      return ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.2),
                  Colors.white.withOpacity(0.06),
                  accentColor.withOpacity(0.12),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                child,
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.35),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withOpacity(0.08),
                        ],
                        stops: const [0.0, 0.25, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String? assetPath;
    if (cleanTitle.contains('upwork')) {
      assetPath = 'assets/cropped/logo_upwork.png';
    } else if (cleanTitle.contains('paypal')) {
      assetPath = 'assets/cropped/logo_paypal.png';
    } else if (cleanTitle.contains('youtube')) {
      assetPath = 'assets/cropped/logo_youtube.png';
    } else if (cleanTitle.contains('starbucks')) {
      assetPath = 'assets/cropped/logo_starbucks.png';
    } else if (cleanTitle.contains('netflix')) {
      return buildGlassContainer(
        isIncome: isIncome,
        child: const Center(
          child: Text(
            'N',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
      );
    } else if (cleanTitle.contains('transfer') ||
        cleanTitle.contains('send') ||
        cleanTitle.contains('john')) {
      assetPath = 'assets/cropped/profile_icon.png';
    }

    if (assetPath != null) {
      return buildGlassContainer(
        isIncome: isIncome,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              final primaryColor = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;
              return Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: primaryColor,
                size: 22,
              );
            },
          ),
        ),
      );
    }

    final primaryColor = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;
    return buildGlassContainer(
      isIncome: isIncome,
      child: Center(
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: primaryColor,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBillIcon(String name) {
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

    if (assetPath != null) {
      return Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.receipt_long_rounded,
        color: Color(0xFF64748B),
        size: 22,
      ),
    );
  }

  void _showPaySimulator(BuildContext context) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (result != null && mounted) {
      Get.snackbar(
        'Payment Processed',
        'Scanned QR: $result',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2F7E79),
        colorText: Colors.white,
      );
    }
  }

  void _showSendSimulator(BuildContext context) {
    final isDark = Get.isDarkMode;
    final recipientController = TextEditingController();
    final amountController = TextEditingController();
    String selectedWalletIdForSend = walletController.wallets.isNotEmpty
        ? walletController.wallets[0].id
        : 'wallet_1';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 40,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Send Money',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: recipientController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Name or Email',
                      hintText: 'e.g. John Doe',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (\$)',
                      hintText: '0.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select Wallet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedWalletIdForSend,
                    dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: walletController.wallets.map((wallet) {
                      return DropdownMenuItem<String>(
                        value: wallet.id,
                        child: Text('${wallet.name} (\$${wallet.balance.toStringAsFixed(2)})'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedWalletIdForSend = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final recipient = recipientController.text.trim();
                      final amountStr = amountController.text.trim();
                      if (recipient.isEmpty || amountStr.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill in all fields.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      final amount = double.tryParse(amountStr);
                      if (amount == null || amount <= 0) {
                        Get.snackbar(
                          'Error',
                          'Please enter a valid amount.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      final wallet =
                          walletController.wallets.firstWhere((w) => w.id == selectedWalletIdForSend);
                      if (wallet.balance < amount) {
                        Get.snackbar(
                          'Error',
                          'Insufficient balance in selected wallet.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // Process transaction
                      walletController.updateWalletBalance(selectedWalletIdForSend, amount, 'expense');
                      txController.addTransaction(
                        TransactionModel(
                          id: const Uuid().v4(),
                          title: 'Transfer to $recipient',
                          amount: amount,
                          type: 'expense',
                          category: 'Transfer',
                          date: DateTime.now(),
                          walletId: selectedWalletIdForSend,
                          payee: recipient,
                          note: 'Transfer transaction to $recipient',
                          status: 'completed',
                        ),
                      );

                      Get.back();
                      Get.snackbar(
                        'Success',
                        'Sent \$$amountStr to $recipient successfully.',
                        backgroundColor: const Color(0xFF2F7E79),
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F7E79),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Send Payment'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

}

class WalletHeaderWaveClipper extends CustomClipper<Path> {
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
