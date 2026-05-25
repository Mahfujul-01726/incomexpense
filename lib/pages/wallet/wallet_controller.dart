import 'package:get/get.dart';
import '../../data/mock_data.dart';
import '../../models/wallet_model.dart';
import '../../services/preferences_service.dart';

class WalletController extends GetxController {
  final PreferencesService _prefsService = Get.find<PreferencesService>();

  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;

  final rxTotalBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    ever(wallets, (_) => _recalculateTotalBalance());
    loadWallets();
  }

  void _recalculateTotalBalance() {
    rxTotalBalance.value = wallets.fold(0.0, (sum, item) => sum + item.balance);
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    try {
      final loaded = await _prefsService.loadWallets();
      if (loaded.isNotEmpty) {
        wallets.value = loaded;
      } else if (MockData.useMockData) {
        wallets.value = MockData.defaultWallets;
        await saveWallets();
      }
    } catch (e) {
      Get.log("Error loading wallets: $e");
      if (MockData.useMockData) {
        wallets.value = MockData.defaultWallets;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveWallets() async {
    try {
      await _prefsService.saveWallets(wallets.toList());
    } catch (e) {
      Get.log("Error saving wallets: $e");
    }
  }

  void addWallet(WalletModel wallet) {
    wallets.add(wallet);
    saveWallets();
  }

  void updateWalletBalance(String walletId, double amount, String transactionType) {
    final index = wallets.indexWhere((w) => w.id == walletId);
    if (index != -1) {
      final currentWallet = wallets[index];
      final newBalance = transactionType == 'income'
          ? currentWallet.balance + amount
          : currentWallet.balance - amount;
      wallets[index] = WalletModel(
        id: currentWallet.id,
        name: currentWallet.name,
        balance: newBalance,
        cardHolder: currentWallet.cardHolder,
        cardNumber: currentWallet.cardNumber,
        expiryDate: currentWallet.expiryDate,
        type: currentWallet.type,
        colorIndex: currentWallet.colorIndex,
        bankLogo: currentWallet.bankLogo,
      );
      saveWallets();
    }
  }

  double get totalBalance => rxTotalBalance.value;

  String get totalBalanceFormatted {
    return '\$ ${totalBalance.toStringAsFixed(2)}';
  }
}
