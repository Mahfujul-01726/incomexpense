import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/bill_controller.dart';
import '../../models/bill_model.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../home/transaction_details_screen.dart';
import '../home/home_tab.dart';
import 'connect_wallet_screen.dart';

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
  String _selectedWalletId = 'all'; // 'all' or specific wallet ID for filtering
  bool _showConnectWallet = false;

  @override
  Widget build(BuildContext context) {
    if (_showConnectWallet) {
      return ConnectWalletScreen(
        onBack: () => setState(() => _showConnectWallet = false),
      );
    }

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
              alignment: Alignment.center,
              children: [
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
                              Container(
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
                          double balance = 0;
                          if (_selectedWalletId == 'all') {
                            balance = walletController.totalBalance;
                          } else {
                            final idx = walletController.wallets.indexWhere((w) => w.id == _selectedWalletId);
                            if (idx != -1) {
                              balance = walletController.wallets[idx].balance;
                            }
                          }
                          final balanceStr = NumberFormat('#,##0.00').format(balance);
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
                                setState(() {
                                  _showConnectWallet = true;
                                });
                              },
                            ),
                            _buildActionButton(
                              context,
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Connect',
                              onTap: () {
                                setState(() {
                                  _showConnectWallet = true;
                                });
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
            // Leave space for the overlapping card (overlapping is 130 + card height around 230 = 360 total height)
            const SizedBox(height: 150),

            // Horizontal Wallet Filter Chip List
            _buildWalletFilterList(isDark),
            const SizedBox(height: 8),

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

  Widget _buildWalletFilterList(bool isDark) {
    return Obx(() {
      return Container(
        height: 38,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: walletController.wallets.length + 2, // +1 for All, +1 for Add Wallet
          itemBuilder: (context, index) {
            if (index == walletController.wallets.length + 1) {
              // "+ Add Wallet" chip
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  avatar: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF2F7E79)),
                  label: const Text('Add Wallet'),
                  backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                  labelStyle: const TextStyle(
                    color: Color(0xFF2F7E79),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _showConnectWallet = true;
                    });
                  },
                ),
              );
            }

            final isAll = index == 0;
            final walletId = isAll ? 'all' : walletController.wallets[index - 1].id;
            final walletName = isAll ? 'All Wallets' : walletController.wallets[index - 1].name;
            final isSelected = _selectedWalletId == walletId;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(walletName),
                selected: isSelected,
                selectedColor: const Color(0xFF2F7E79),
                backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF666666)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedWalletId = walletId;
                    });
                  }
                },
              ),
            );
          },
        ),
      );
    });
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
      final transactions = txController.transactions.where((tx) {
        if (_selectedWalletId == 'all') return true;
        return tx.walletId == _selectedWalletId;
      }).toList();

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
                _buildBillIcon(bill.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.name,
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
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showPayBillSheet(context, bill),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7E79).withOpacity(isDark ? 0.2 : 0.08),
                    foregroundColor: const Color(0xFF2F7E79),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildTransactionIcon(String title, bool isIncome) {
    final cleanTitle = title.toLowerCase();

    if (cleanTitle.contains('upwork')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF1FDF3),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'up',
          style: TextStyle(
            color: Color(0xFF14A800),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    } else if (cleanTitle.contains('paypal')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F4FC),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.paypal,
          color: Color(0xFF003087),
          size: 22,
        ),
      );
    } else if (cleanTitle.contains('youtube')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFFFECEB),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.red,
          size: 24,
        ),
      );
    } else if (cleanTitle.contains('netflix')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.black87,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'N',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      );
    } else if (cleanTitle.contains('transfer') ||
        cleanTitle.contains('send') ||
        cleanTitle.contains('john')) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/cropped/profile_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person_rounded, color: Colors.purple.shade700, size: 22);
            },
          ),
        ),
      );
    } else {
      final primaryColor = isIncome ? AppTheme.incomeColor : AppTheme.primaryColor;
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: primaryColor,
          size: 20,
        ),
      );
    }
  }

  Widget _buildBillIcon(String name) {
    final cleanName = name.toLowerCase();
    if (cleanName.contains('youtube')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFFFECEB),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Colors.red,
          size: 24,
        ),
      );
    } else if (cleanName.contains('electricity') || cleanName.contains('power')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7ED),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.flash_on_rounded,
          color: Colors.orange,
          size: 22,
        ),
      );
    } else if (cleanName.contains('rent') || cleanName.contains('house')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.home_filled,
          color: Color(0xFF15803D),
          size: 22,
        ),
      );
    } else if (cleanName.contains('spotify') || cleanName.contains('music')) {
      return Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF0FDF4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.music_note_rounded,
          color: Colors.green,
          size: 22,
        ),
      );
    } else {
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
  }

  void _showPaySimulator(BuildContext context) {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(Icons.qr_code_scanner_rounded, size: 64, color: Color(0xFF2F7E79)),
            const SizedBox(height: 16),
            Text(
              'Scan to Pay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align QR code inside the frame to scan and pay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2F7E79), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  'Payment Processed',
                  'Simulated QR scan completed successfully.',
                  snackPosition: SnackPosition.BOTTOM,
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
              child: const Text('Simulate Scan'),
            ),
          ],
        ),
      ),
    );
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

  void _showPayBillSheet(BuildContext context, BillModel bill) {
    final isDark = Get.isDarkMode;
    if (bill.isPaid) {
      Get.snackbar(
        'Already Paid',
        'This bill is already settled.',
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
              'Pay Bill',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bill: ${bill.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              'Provider: ${bill.provider}',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54),
            ),
            Text(
              'Amount: \$${bill.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F7E79)),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Wallet to Pay From',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: walletController.wallets.length,
              itemBuilder: (context, index) {
                final wallet = walletController.wallets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  color: isDark ? AppTheme.darkBg : Colors.white,
                  child: ListTile(
                    title: Text(wallet.name),
                    subtitle: Text('Balance: \$${wallet.balance.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      if (wallet.balance < bill.amount) {
                        Get.snackbar(
                          'Insufficient Balance',
                          'Selected wallet does not have enough balance to pay this bill.',
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                        return;
                      }

                      // Deduct from wallet
                      walletController.updateWalletBalance(wallet.id, bill.amount, 'expense');
                      // Mark bill as paid
                      final success = billController.payBill(bill.id, wallet.id);

                      Get.back();
                      if (success) {
                        Get.snackbar(
                          'Payment Completed',
                          'Paid \$${bill.amount.toStringAsFixed(2)} for ${bill.name} successfully.',
                          backgroundColor: const Color(0xFF2F7E79),
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
