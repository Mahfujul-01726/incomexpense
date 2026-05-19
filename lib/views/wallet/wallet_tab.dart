import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/wallet_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/wallet_model.dart';
import '../../theme/app_theme.dart';
import 'connect_wallet_screen.dart';
import '../home/transaction_details_screen.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final walletController = Get.find<WalletController>();
  final txController = Get.find<TransactionController>();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _activeCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded, color: AppTheme.primaryColor),
            onPressed: () => Get.to(() => const ConnectWalletScreen()),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Cards Carousel
            _buildCardsCarousel(context),
            const SizedBox(height: 28),

            // Card details header or quick summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Wallet Transactions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),

            // List of transactions for selected card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(() {
                if (walletController.wallets.isEmpty) {
                  return const SizedBox.shrink();
                }
                final activeWallet = walletController.wallets[_activeCardIndex];
                final walletTx = txController.transactions
                    .where((t) => t.walletId == activeWallet.id)
                    .toList();

                if (walletTx.isEmpty) {
                  return _buildEmptyTransactions(context);
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: walletTx.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = walletTx[index];
                    return _buildWalletTransactionItem(context, tx);
                  },
                );
              }),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCardsCarousel(BuildContext context) {
    return Obx(() {
      if (walletController.wallets.isEmpty) {
        return _buildEmptyWallets(context);
      }

      return SizedBox(
        height: 230,
        child: PageView.builder(
          controller: _pageController,
          itemCount: walletController.wallets.length,
          onPageChanged: (index) {
            setState(() {
              _activeCardIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final wallet = walletController.wallets[index];
            return _buildCardItem(context, wallet, index == _activeCardIndex);
          },
        ),
      );
    });
  }

  Widget _buildCardItem(BuildContext context, WalletModel wallet, bool isActive) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final gradientColors = AppTheme.cardGradients[wallet.colorIndex % AppTheme.cardGradients.length];

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.93,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(isActive ? 0.35 : 0.15),
              blurRadius: isActive ? 20 : 10,
              offset: Offset(0, isActive ? 10 : 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(wallet.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Bank Logo simulation
                _buildBankLogo(wallet.bankLogo),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.cardNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wallet.cardHolder.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPIRES',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          wallet.expiryDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankLogo(String? logo) {
    IconData iconData;
    String text;
    Color color;

    switch (logo?.toLowerCase()) {
      case 'paypal':
        iconData = Icons.paypal;
        text = 'PayPal';
        color = const Color(0xFF003087);
        break;
      case 'chase':
        iconData = Icons.account_balance;
        text = 'Chase';
        color = Colors.white;
        break;
      case 'visa':
      default:
        iconData = Icons.credit_card;
        text = 'Visa';
        color = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletTransactionItem(BuildContext context, dynamic tx) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isIncome = tx.type == 'income';
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    final sign = isIncome ? '+' : '-';

    return GestureDetector(
      onTap: () => Get.to(() => TransactionDetailsScreen(transaction: tx)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: (isIncome ? AppTheme.incomeColor : AppTheme.primaryColor).withOpacity(0.1),
              child: Icon(
                isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isIncome ? AppTheme.incomeColor : AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(tx.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign${formatter.format(tx.amount).replaceAll('\$', '')}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWallets(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card_off_rounded, size: 48, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          const Text('No Wallets Configured', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.to(() => const ConnectWalletScreen()),
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'No transactions logged on this wallet.',
        style: TextStyle(
          color: Get.isDarkMode ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          fontSize: 13,
        ),
      ),
    );
  }
}
