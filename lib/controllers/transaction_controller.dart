import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import 'wallet_controller.dart';

class TransactionController extends GetxController {
  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;

  // Statistics filters
  var selectedPeriod = 'Week'.obs; // 'Week' | 'Month' | 'Year'
  var selectedType = 'expense'.obs; // 'income' | 'expense'

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final transString = prefs.getString('transactions');
      if (transString != null) {
        final List<dynamic> jsonList = jsonDecode(transString);
        transactions.value = jsonList.map((e) => TransactionModel.fromJson(e)).toList();
        if (transactions.length == 4 && !transactions.any((tx) => tx.id == 't_5')) {
          transactions.add(TransactionModel(
            id: 't_5',
            title: 'Starbucks',
            amount: 150.00,
            type: 'expense',
            category: 'Food & Dining',
            date: DateTime(2022, 1, 12, 8, 30),
            walletId: 'wallet_1',
            payee: 'Starbucks Coffee',
            note: 'Coffee and snacks',
            status: 'completed',
          ));
          await saveTransactions();
        }
      } else {
        // Load default mock data
        final now = DateTime.now();
        transactions.value = [
          TransactionModel(
            id: 't_1',
            title: 'Upwork',
            amount: 850.00,
            type: 'income',
            category: 'Freelance',
            date: now,
            walletId: 'wallet_1',
            payee: 'Upwork Global Inc.',
            note: 'Freelance mobile app development milestone',
            status: 'completed',
          ),
          TransactionModel(
            id: 't_2',
            title: 'Transfer',
            amount: 85.00,
            type: 'expense',
            category: 'Transfer',
            date: now.subtract(const Duration(days: 1)),
            walletId: 'wallet_1',
            payee: 'Bank Account Transfer',
            note: 'Peer to peer transfer',
            status: 'completed',
          ),
          TransactionModel(
            id: 't_3',
            title: 'Paypal',
            amount: 1406.00,
            type: 'income',
            category: 'Consulting',
            date: DateTime(2022, 1, 30, 14, 30),
            walletId: 'wallet_1',
            payee: 'PayPal Inc.',
            note: 'Online payment received',
            status: 'completed',
          ),
          TransactionModel(
            id: 't_4',
            title: 'Youtube',
            amount: 11.99,
            type: 'expense',
            category: 'Subscriptions',
            date: DateTime(2022, 1, 16, 9, 15),
            walletId: 'wallet_1',
            payee: 'Google Youtube Premium',
            note: 'Monthly premium subscription fee',
            status: 'completed',
          ),
          TransactionModel(
            id: 't_5',
            title: 'Starbucks',
            amount: 150.00,
            type: 'expense',
            category: 'Food & Dining',
            date: DateTime(2022, 1, 12, 8, 30),
            walletId: 'wallet_1',
            payee: 'Starbucks Coffee',
            note: 'Coffee and snacks',
            status: 'completed',
          ),
        ];
        await saveTransactions();
      }
    } catch (e) {
      Get.log("Error loading transactions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transString = jsonEncode(transactions.map((e) => e.toJson()).toList());
      await prefs.setString('transactions', transString);
    } catch (e) {
      Get.log("Error saving transactions: $e");
    }
  }

  void addTransaction(TransactionModel transaction) {
    transactions.insert(0, transaction);
    saveTransactions();

    // Update wallet balance
    try {
      final walletController = Get.find<WalletController>();
      walletController.updateWalletBalance(
        transaction.walletId,
        transaction.amount,
        transaction.type,
      );
    } catch (e) {
      Get.log("WalletController not found, balance not updated automatically: $e");
    }
  }

  void deleteTransaction(String transactionId) {
    final index = transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = transactions[index];
      transactions.removeAt(index);
      saveTransactions();

      // Reverse wallet balance update
      try {
        final walletController = Get.find<WalletController>();
        // If it was income, we deduct it. If it was expense, we add it back.
        final reverseType = transaction.type == 'income' ? 'expense' : 'income';
        walletController.updateWalletBalance(
          transaction.walletId,
          transaction.amount,
          reverseType,
        );
      } catch (e) {
        Get.log("WalletController not found: $e");
      }
    }
  }

  // Get total income
  double get totalIncome {
    return transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Get total expenses
  double get totalExpenses {
    return transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Filtered transactions for charts
  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    DateTime threshold;

    if (selectedPeriod.value == 'Day') {
      threshold = now.subtract(const Duration(days: 1));
    } else if (selectedPeriod.value == 'Week') {
      threshold = now.subtract(const Duration(days: 7));
    } else if (selectedPeriod.value == 'Month') {
      threshold = now.subtract(const Duration(days: 30));
    } else {
      threshold = now.subtract(const Duration(days: 365));
    }

    return transactions
        .where((t) => t.type == selectedType.value && t.date.isAfter(threshold))
        .toList();
  }

  // Get category-wise spending
  Map<String, double> get categoryBreakdown {
    final list = filteredTransactions;
    final breakdown = <String, double>{};
    for (var t in list) {
      breakdown[t.category] = (breakdown[t.category] ?? 0.0) + t.amount;
    }
    return breakdown;
  }
}
