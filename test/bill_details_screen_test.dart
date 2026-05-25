import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:incomexpense/controllers/bill_controller.dart';
import 'package:incomexpense/controllers/wallet_controller.dart';
import 'package:incomexpense/controllers/transaction_controller.dart';
import 'package:incomexpense/models/bill_model.dart';
import 'package:incomexpense/views/bills/bill_details_screen.dart';

void main() {
  testWidgets('BillDetailsScreen renders details correctly', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

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
