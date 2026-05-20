import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/bill_model.dart';
import '../models/transaction_model.dart';
import 'transaction_controller.dart';

class BillController extends GetxController {
  var bills = <BillModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  Future<void> loadBills() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Migration: force reload default bills if version mismatch
      final billVersion = prefs.getInt('bills_version');
      if (billVersion == null || billVersion < 2) {
        await prefs.remove('bills');
        await prefs.setInt('bills_version', 2);
      }

      final billsString = prefs.getString('bills');
      if (billsString != null) {
        final List<dynamic> jsonList = jsonDecode(billsString);
        bills.value = jsonList.map((e) => BillModel.fromJson(e)).toList();
      } else {
        // Load default mock bills
        final now = DateTime.now();
        bills.value = [
          BillModel(
            id: 'bill_1',
            name: 'YouTube',
            amount: 12.99,
            dueDate: now.add(const Duration(days: 3)),
            isPaid: false,
            category: 'Entertainment',
            autoPay: true,
            provider: 'YouTube LLC',
          ),
          BillModel(
            id: 'bill_2',
            name: 'Electricity',
            amount: 85.40,
            dueDate: now.add(const Duration(days: 7)),
            isPaid: false,
            category: 'Utilities',
            autoPay: false,
            provider: 'Metro Power Utility',
          ),
          BillModel(
            id: 'bill_3',
            name: 'House Rent',
            amount: 1200.00,
            dueDate: now.add(const Duration(days: 1)),
            isPaid: false,
            category: 'Housing',
            autoPay: false,
            provider: 'Sunset Properties',
          ),
          BillModel(
            id: 'bill_4',
            name: 'Spotify',
            amount: 9.99,
            dueDate: now.add(const Duration(days: 10)),
            isPaid: false,
            category: 'Entertainment',
            autoPay: true,
            provider: 'Spotify AB',
          ),
        ];
        await saveBills();
      }
    } catch (e) {
      Get.log("Error loading bills: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final billsString = jsonEncode(bills.map((e) => e.toJson()).toList());
      await prefs.setString('bills', billsString);
    } catch (e) {
      Get.log("Error saving bills: $e");
    }
  }

  void addBill(BillModel bill) {
    bills.add(bill);
    saveBills();
  }

  void toggleAutoPay(String id) {
    final index = bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      bills[index] = bills[index].copyWith(autoPay: !bills[index].autoPay);
      saveBills();
    }
  }

  bool payBill(String id, String walletId) {
    final index = bills.indexWhere((b) => b.id == id);
    if (index != -1) {
      final bill = bills[index];
      if (bill.isPaid) return false;

      // Mark as paid
      bills[index] = bills[index].copyWith(isPaid: true);
      saveBills();

      // Create transaction
      try {
        final txController = Get.find<TransactionController>();
        final newTx = TransactionModel(
          id: const Uuid().v4(),
          title: 'Paid: ${bill.name}',
          amount: bill.amount,
          type: 'expense',
          category: bill.category,
          date: DateTime.now(),
          walletId: walletId,
          payee: bill.provider,
          note: 'Automatic or manual payment for recurring bill: ${bill.name}',
          status: 'completed',
        );
        txController.addTransaction(newTx);
        return true;
      } catch (e) {
        Get.log("TransactionController not found when paying bill: $e");
      }
    }
    return false;
  }
}
