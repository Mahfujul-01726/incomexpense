import 'package:get/get.dart';
import '../pages/bills/bill_controller.dart';

class BillsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BillController(), fenix: true);
  }
}
