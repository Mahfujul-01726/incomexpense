import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incomexpense/services/preferences_service.dart';
import 'package:incomexpense/constants/app_constants.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  test('PreferencesService migrates plaintext data to secure storage on init', () async {
    // 1. Setup mock values in SharedPreferences (the insecure storage)
    SharedPreferences.setMockInitialValues({
      AppConstants.prefProfileName: 'Insecure John',
      AppConstants.prefProfileEmail: 'john@insecure.com',
      AppConstants.prefProfilePhone: '+1 234 567 890',
      AppConstants.prefBiometricsEnabled: true,
      AppConstants.prefTransactions: '[{"id": "t1", "title": "Lunch", "amount": 10.5, "type": "expense", "category": "Food", "date": "2026-05-25T10:00:00.000", "walletId": "w1", "payee": "McDonalds", "note": "Burger", "status": "completed"}]',
    });

    // Setup mock empty values in FlutterSecureStorage
    FlutterSecureStorage.setMockInitialValues({});

    // 2. Initialize PreferencesService
    final service = PreferencesService();
    await service.init();

    // 3. Verify SharedPreferences keys are deleted
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(AppConstants.prefProfileName), isFalse);
    expect(prefs.containsKey(AppConstants.prefProfileEmail), isFalse);
    expect(prefs.containsKey(AppConstants.prefProfilePhone), isFalse);
    expect(prefs.containsKey(AppConstants.prefBiometricsEnabled), isFalse);
    expect(prefs.containsKey(AppConstants.prefTransactions), isFalse);

    // 4. Verify data can be loaded securely from PreferencesService (meaning it migrated)
    final name = await service.loadProfileName();
    final email = await service.loadProfileEmail();
    final phone = await service.loadProfilePhone();
    final biometrics = await service.loadBiometricsEnabled();
    final transactions = await service.loadTransactions();

    expect(name, equals('Insecure John'));
    expect(email, equals('john@insecure.com'));
    expect(phone, equals('+1 234 567 890'));
    expect(biometrics, isTrue);
    expect(transactions.length, equals(1));
    expect(transactions[0].id, equals('t1'));
    expect(transactions[0].title, equals('Lunch'));
    expect(transactions[0].amount, equals(10.5));
  });
}
