import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/mock_data.dart';
import '../../models/bill_model.dart';
import '../../models/transaction_model.dart';
import '../../services/preferences_service.dart';
import '../home/transaction_controller.dart';

class BillController extends GetxController {
  final PreferencesService _prefsService = Get.find<PreferencesService>();

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
      final loaded = await _prefsService.loadBills();
      if (loaded.isNotEmpty) {
        bills.value = loaded;
      } else if (MockData.useMockData) {
        bills.value = MockData.defaultBills;
        await saveBills();
      }
    } catch (e) {
      Get.log("Error loading bills: $e");
      if (MockData.useMockData) {
        bills.value = MockData.defaultBills;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBills() async {
    try {
      await _prefsService.saveBills(bills.toList());
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

  bool payBill(String id, String walletId, {bool createTransaction = false}) {
    final index = bills.indexWhere((b) => b.id == id);
    if (index == -1) return false;

    final bill = bills[index];
    if (bill.isPaid) return false;

    bills[index] = bills[index].copyWith(isPaid: true);
    saveBills();

    if (createTransaction) {
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
      } catch (e) {
        Get.log("TransactionController not found when paying bill: $e");
      }
    }
    return true;
  }
}
