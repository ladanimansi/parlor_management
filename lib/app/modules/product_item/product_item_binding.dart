import 'package:get/get.dart';
import 'product_item_controller.dart';

class ProductItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductItemController>(
      () => ProductItemController(),
    );
  }
}
