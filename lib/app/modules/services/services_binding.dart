import 'package:get/get.dart';
import 'services_controller.dart';
import '../product_item/product_item_controller.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductItemController>()) {
      Get.put<ProductItemController>(ProductItemController(), permanent: false);
    }
    Get.lazyPut<ServicesController>(
      () => ServicesController(),
    );
  }
}
