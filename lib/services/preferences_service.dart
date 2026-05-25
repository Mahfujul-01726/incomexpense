import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import '../models/bill_model.dart';
import '../constants/app_constants.dart';

class PreferencesService extends GetxService {
  SharedPreferences? _prefs;
  late final FlutterSecureStorage _securePrefs;

  Future<PreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _securePrefs = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await _migrateIfNecessary();
    return this;
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _migrateIfNecessary() async {
    final p = await prefs;

    // Define sensitive keys we want to migrate
    final sensitiveKeys = [
      AppConstants.prefTransactions,
      AppConstants.prefWallets,
      AppConstants.prefBills,
      AppConstants.prefProfileName,
      AppConstants.prefProfileEmail,
      AppConstants.prefProfilePhone,
    ];

    for (final key in sensitiveKeys) {
      if (p.containsKey(key)) {
        final val = p.getString(key);
        if (val != null) {
          await _securePrefs.write(key: key, value: val);
        }
        await p.remove(key);
      }
    }

    // Also migrate prefBiometricsEnabled (boolean in SharedPreferences)
    if (p.containsKey(AppConstants.prefBiometricsEnabled)) {
      final val = p.getBool(AppConstants.prefBiometricsEnabled);
      if (val != null) {
        await _securePrefs.write(
          key: AppConstants.prefBiometricsEnabled,
          value: val.toString(),
        );
      }
      await p.remove(AppConstants.prefBiometricsEnabled);
    }
  }

  Future<List<TransactionModel>> loadTransactions() async {
    final data = await _securePrefs.read(key: AppConstants.prefTransactions);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final data = jsonEncode(transactions.map((e) => e.toJson()).toList());
    await _securePrefs.write(key: AppConstants.prefTransactions, value: data);
  }

  Future<List<WalletModel>> loadWallets() async {
    final p = await prefs;
    final migrated = p.getBool(AppConstants.prefWalletsMigrated);
    if (migrated != true) {
      await _securePrefs.delete(key: AppConstants.prefWallets);
      await p.setBool(AppConstants.prefWalletsMigrated, true);
    }
    final data = await _securePrefs.read(key: AppConstants.prefWallets);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => WalletModel.fromJson(e)).toList();
  }

  Future<void> saveWallets(List<WalletModel> wallets) async {
    final data = jsonEncode(wallets.map((e) => e.toJson()).toList());
    await _securePrefs.write(key: AppConstants.prefWallets, value: data);
  }

  Future<List<BillModel>> loadBills() async {
    final p = await prefs;
    final billVersion = p.getInt(AppConstants.prefBillsVersion);
    if (billVersion == null || billVersion < 4) {
      await _securePrefs.delete(key: AppConstants.prefBills);
      await p.setInt(AppConstants.prefBillsVersion, 4);
      return [];
    }
    final data = await _securePrefs.read(key: AppConstants.prefBills);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => BillModel.fromJson(e)).toList();
  }

  Future<void> saveBills(List<BillModel> bills) async {
    final data = jsonEncode(bills.map((e) => e.toJson()).toList());
    await _securePrefs.write(key: AppConstants.prefBills, value: data);
  }

  Future<String> loadProfileName() async {
    return await _securePrefs.read(key: AppConstants.prefProfileName) ??
        AppConstants.defaultProfileName;
  }

  Future<String> loadProfileEmail() async {
    return await _securePrefs.read(key: AppConstants.prefProfileEmail) ??
        AppConstants.defaultProfileEmail;
  }

  Future<String> loadProfilePhone() async {
    return await _securePrefs.read(key: AppConstants.prefProfilePhone) ??
        AppConstants.defaultProfilePhone;
  }

  Future<bool> loadIsDarkTheme() async {
    final p = await prefs;
    return p.getBool(AppConstants.prefIsDarkTheme) ?? false;
  }

  Future<bool> loadReceiveNotifications() async {
    final p = await prefs;
    return p.getBool(AppConstants.prefReceiveNotifications) ?? true;
  }

  Future<bool> loadBiometricsEnabled() async {
    final val = await _securePrefs.read(
      key: AppConstants.prefBiometricsEnabled,
    );
    return val == 'true';
  }

  Future<void> saveProfile(String name, String email, String phone) async {
    await _securePrefs.write(key: AppConstants.prefProfileName, value: name);
    await _securePrefs.write(key: AppConstants.prefProfileEmail, value: email);
    await _securePrefs.write(key: AppConstants.prefProfilePhone, value: phone);
  }

  Future<void> setDarkTheme(bool value) async {
    final p = await prefs;
    await p.setBool(AppConstants.prefIsDarkTheme, value);
  }

  Future<void> setReceiveNotifications(bool value) async {
    final p = await prefs;
    await p.setBool(AppConstants.prefReceiveNotifications, value);
  }

  Future<void> setBiometricsEnabled(bool value) async {
    await _securePrefs.write(
      key: AppConstants.prefBiometricsEnabled,
      value: value.toString(),
    );
  }

  Future<bool> getOnboardingCompleted() async {
    final p = await prefs;
    return p.getBool(AppConstants.prefOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final p = await prefs;
    await p.setBool(AppConstants.prefOnboardingCompleted, value);
  }
}
