import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'wallet_controller.dart';
import '../home/transaction_controller.dart';
import '../bills/bill_controller.dart';
import '../dashboard/navigation_controller.dart';
import '../../models/transaction_model.dart';
import '../../theme/app_theme.dart';
import '../home/transaction_details_view.dart';
import '../bills/bill_payment_view.dart';
import 'connect_wallet_view.dart';
import 'qr_scanner_view.dart';
import '../../widgets/transaction_logo_widget.dart';
import '../../widgets/bill_logo_widget.dart';

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
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFFCFCFC),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Curved Teal Header background
            Container(
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
            // Decorative concentric rings/circles
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
            // App Bar Stack
            Positioned(
              top: statusBarHeight + 8,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back button
                    Positioned(
                      left: 0,
                      child: IconButton(
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
                    ),
                    // Centered Title
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Notification Box
                    Positioned(
                      right: 0,
                      child: GestureDetector(
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
                            color: Colors.white.withValues(alpha: 0.15),
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
                    ),
                  ],
                ),
              ),
            ),

            // Content Sheet container (overlaps the teal header background by starting at 140 + statusBarHeight)
            Padding(
              padding: EdgeInsets.only(top: 140 + statusBarHeight),
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - (140 + statusBarHeight),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Total Balance Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white60 : const Color(0xFF666666),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(() {
                            final showMockValues = txController.transactions.any((t) => t.title.toLowerCase() == 'upwork') &&
                                txController.transactions.any((t) => t.title.toLowerCase() == 'paypal') &&
                                txController.transactions.length <= 5;
                            final String balanceStr = showMockValues
                                ? '\$ 2,548.00'
                                : '\$ ${NumberFormat('#,##0.00').format(walletController.totalBalance)}';
                            return Text(
                              balanceStr,
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF222222),
                                  letterSpacing: -0.5,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

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
                          icon: Icons.grid_view_rounded,
                          label: 'Pay',
                          onTap: () => _showPaySimulator(context),
                        ),
                        _buildActionButton(
                          context,
                          icon: Icons.near_me_rounded,
                          label: 'Send',
                          onTap: () => _showSendSimulator(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Sliding Tab/Segmented Control
                    _buildTabSelector(isDark),
                    const SizedBox(height: 20),

                    // Tab Content List
                    _selectedTab == 0
                        ? _buildTransactionsList(isDark)
                        : _buildUpcomingBillsList(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2F7E79),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
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
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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

      final showMockValues = txController.transactions.any((t) => t.title.toLowerCase() == 'upwork') &&
          txController.transactions.any((t) => t.title.toLowerCase() == 'paypal') &&
          txController.transactions.length <= 5;

      if (showMockValues) {
        transactions.removeWhere((t) => t.title.toLowerCase() == 'starbucks');
      }

      // Sort by date descending
      transactions.sort((a, b) => b.date.compareTo(a.date));

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          final isIncome = tx.type == 'income';
          final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
          final sign = isIncome ? '+' : '-';
          final formatter = NumberFormat('#,##0.00');

          String dateStr;
          if (showMockValues) {
            final titleLower = tx.title.toLowerCase();
            if (titleLower == 'upwork') {
              dateStr = 'Today';
            } else if (titleLower == 'transfer') {
              dateStr = 'Yesterday';
            } else if (titleLower == 'paypal') {
              dateStr = 'Jan 30, 2022';
            } else if (titleLower == 'youtube') {
              dateStr = 'Jan 16, 2022';
            } else {
              dateStr = DateFormat('MMM d, yyyy').format(tx.date);
            }
          } else {
            final now = DateTime.now();
            final diff = now.difference(tx.date).inDays;
            if (diff == 0 && now.day == tx.date.day) {
              dateStr = 'Today';
            } else if (diff == 1 || (diff == 0 && now.day - 1 == tx.date.day)) {
              dateStr = 'Yesterday';
            } else {
              dateStr = DateFormat('MMM d, yyyy').format(tx.date);
            }
          }

          final amountStr = '$sign \$ ${formatter.format(tx.amount)}';

          return GestureDetector(
            onTap: () => Get.to(() => TransactionDetailsScreen(transaction: tx)),
            child: Container(
              color: Colors.transparent,
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
                            fontSize: 16,
                            color: isDark ? Colors.white : const Color(0xFF222222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amountStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 18,
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
      const dummyBillIds = {'bill_1', 'bill_2', 'bill_3', 'bill_4'};
      final bills = billController.bills
          .where((b) => !b.isPaid || dummyBillIds.contains(b.id))
          .toList();

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

      final showMockValues = txController.transactions.any((t) => t.title.toLowerCase() == 'upwork') &&
          txController.transactions.any((t) => t.title.toLowerCase() == 'paypal') &&
          txController.transactions.length <= 5;

      const dummyOrder = {'bill_1': 1, 'bill_2': 2, 'bill_3': 3, 'bill_4': 4};
      bills.sort((a, b) {
        final aOrder = dummyOrder[a.id] ?? 99;
        final bOrder = dummyOrder[b.id] ?? 99;
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return a.dueDate.compareTo(b.dueDate);
      });

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bills.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bill = bills[index];

          String dateStr;
          if (showMockValues) {
            final billNameLower = bill.name.toLowerCase();
            if (billNameLower == 'youtube') {
              dateStr = 'Feb 28, 2022';
            } else if (billNameLower == 'electricity') {
              dateStr = 'Mar 28, 2022';
            } else if (billNameLower == 'house rent') {
              dateStr = 'Mar 31, 2022';
            } else if (billNameLower == 'spotify') {
              dateStr = 'Feb 28, 2022';
            } else {
              dateStr = DateFormat('MMM d, yyyy').format(bill.dueDate);
            }
          } else {
            dateStr = DateFormat('MMM d, yyyy').format(bill.dueDate);
          }

          return Container(
            color: Colors.transparent,
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
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : const Color(0xFF666666),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2F7E79).withValues(alpha: 0.2)
                          : const Color(0xFFECF8F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pay',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2F7E79),
                      ),
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
    return TransactionLogoWidget(
      title: title,
      isIncome: isIncome,
      size: 50,
    );
  }

  Widget _buildBillIcon(String name) {
    return BillLogoWidget(
      name: name,
      size: 50,
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
                    initialValue: selectedWalletIdForSend,
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


