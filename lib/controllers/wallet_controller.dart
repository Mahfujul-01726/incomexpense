import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  var wallets = <WalletModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadWallets();
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clear old persisted defaults (migration)
      final migrated = prefs.getBool('wallets_migrated');
      if (migrated != true) {
        await prefs.remove('wallets');
        await prefs.setBool('wallets_migrated', true);
      }
      final walletsString = prefs.getString('wallets');
      if (walletsString != null) {
        final List<dynamic> jsonList = jsonDecode(walletsString);
        wallets.value = jsonList.map((e) => WalletModel.fromJson(e)).toList();
      }
    } catch (e) {
      Get.log("Error loading wallets: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveWallets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletsString = jsonEncode(wallets.map((e) => e.toJson()).toList());
      await prefs.setString('wallets', walletsString);
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
      double newBalance = currentWallet.balance;
      if (transactionType == 'income') {
        newBalance += amount;
      } else {
        newBalance -= amount;
      }
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

  double get totalBalance {
    return wallets.fold(0.0, (sum, item) => sum + item.balance);
  }
}
