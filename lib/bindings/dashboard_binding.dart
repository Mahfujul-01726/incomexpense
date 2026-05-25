import 'package:get/get.dart';
import '../pages/dashboard/navigation_controller.dart';
import '../pages/home/transaction_controller.dart';
import '../pages/wallet/wallet_controller.dart';
import '../pages/profile/profile_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController());
    Get.lazyPut(() => WalletController(), fenix: true);
    Get.lazyPut(() => TransactionController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}
