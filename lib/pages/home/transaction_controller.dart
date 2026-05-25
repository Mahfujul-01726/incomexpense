import 'package:get/get.dart';
import '../../data/mock_data.dart';
import '../../models/transaction_model.dart';
import '../../services/preferences_service.dart';
import '../wallet/wallet_controller.dart';

class TransactionController extends GetxController {
  final PreferencesService _prefsService = Get.find<PreferencesService>();

  var transactions = <TransactionModel>[].obs;
  var isLoading = false.obs;
  var selectedPeriod = 'Week'.obs;
  var selectedType = 'expense'.obs;

  final rxTotalIncome = 0.0.obs;
  final rxTotalExpenses = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(transactions, (_) => _recalculateTotals());
    loadTransactions();
  }

  void _recalculateTotals() {
    double income = 0.0;
    double expenses = 0.0;
    for (final t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
    }
    rxTotalIncome.value = income;
    rxTotalExpenses.value = expenses;
  }

  Future<void> loadTransactions() async {
    isLoading.value = true;
    try {
      final loaded = await _prefsService.loadTransactions();
      if (loaded.isNotEmpty) {
        transactions.value = loaded;
      } else if (MockData.useMockData) {
        transactions.value = MockData.defaultTransactions;
        await saveTransactions();
      }
    } catch (e) {
      Get.log("Error loading transactions: $e");
      if (MockData.useMockData) {
        transactions.value = MockData.defaultTransactions;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveTransactions() async {
    try {
      await _prefsService.saveTransactions(transactions.toList());
    } catch (e) {
      Get.log("Error saving transactions: $e");
    }
  }

  void addTransaction(TransactionModel transaction) {
    transactions.insert(0, transaction);
    saveTransactions();
    try {
      Get.find<WalletController>().updateWalletBalance(
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
      try {
        final walletController = Get.find<WalletController>();
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

  double get totalIncome => rxTotalIncome.value;

  double get totalExpenses => rxTotalExpenses.value;

  List<TransactionModel> get filteredTransactions {
    final now = DateTime.now();
    final threshold = switch (selectedPeriod.value) {
      'Day' => now.subtract(const Duration(days: 1)),
      'Week' => now.subtract(const Duration(days: 7)),
      'Month' => now.subtract(const Duration(days: 30)),
      _ => now.subtract(const Duration(days: 365)),
    };
    return transactions
        .where((t) => t.type == selectedType.value && t.date.isAfter(threshold))
        .toList();
  }

  Map<String, double> get categoryBreakdown {
    final list = filteredTransactions;
    final breakdown = <String, double>{};
    for (final t in list) {
      breakdown[t.category] = (breakdown[t.category] ?? 0.0) + t.amount;
    }
    return breakdown;
  }
}
