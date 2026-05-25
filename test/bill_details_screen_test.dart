import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:incomexpense/services/preferences_service.dart';
import 'package:incomexpense/pages/dashboard/navigation_controller.dart';
import 'package:incomexpense/pages/bills/bill_controller.dart';
import 'package:incomexpense/pages/wallet/wallet_controller.dart';
import 'package:incomexpense/pages/home/transaction_controller.dart';
import 'package:incomexpense/models/bill_model.dart';
import 'package:incomexpense/pages/bills/bill_details_view.dart';

void main() {
  testWidgets('BillDetailsScreen renders details correctly', (WidgetTester tester) async {
    // Mock SharedPreferences and FlutterSecureStorage
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    // Inject PreferencesService first
    Get.put(PreferencesService());
    Get.put(NavigationController());

    // Inject controllers
    final walletController = Get.put(WalletController());
    Get.put(TransactionController());
    final billController = Get.put(BillController());

    // Load controllers data
    await walletController.loadWallets();
    await billController.loadBills();

    final testBill = BillModel(
      id: 'test_bill_1',
      name: 'Youtube Premium',
      amount: 11.99,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      isPaid: false,
      category: 'Entertainment',
      autoPay: false,
      provider: 'YouTube LLC',
    );

    // Build the widget
    await tester.pumpWidget(GetMaterialApp(
      home: BillDetailsScreen(bill: testBill),
    ));

    // Pump to let the widget tree stabilize and render
    await tester.pumpAndSettle();

    // Verify elements are displayed
    expect(find.text('Bill Details'), findsOneWidget);
    expect(find.text('Youtube Premium'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('\$ 11.99'), findsOneWidget);
    expect(find.text('Pay Now'), findsOneWidget);
  });
}
