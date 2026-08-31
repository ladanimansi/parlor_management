import 'package:get/get.dart';
import 'order_preparation_controller.dart';
import '../product_category/product_category_controller.dart';
import '../product_item/product_item_controller.dart';

class OrderPreparationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductCategoryController>()) {
      Get.put<ProductCategoryController>(ProductCategoryController(), permanent: false);
    }
    if (!Get.isRegistered<ProductItemController>()) {
      Get.put<ProductItemController>(ProductItemController(), permanent: false);
    }
    Get.lazyPut<OrderPreparationController>(
      () => OrderPreparationController(),
    );
  }
}
