import 'package:get/get.dart';
import 'order_allocation_controller.dart';

class OrderAllocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderAllocationController>(() => OrderAllocationController());
  }
}
