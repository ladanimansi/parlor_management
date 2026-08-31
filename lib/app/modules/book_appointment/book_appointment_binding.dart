import 'package:get/get.dart';
import 'book_appointment_controller.dart';
import '../product_category/product_category_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure ProductCategoryController is available for service selector
    if (!Get.isRegistered<ProductCategoryController>()) {
      Get.put<ProductCategoryController>(ProductCategoryController(), permanent: false);
    }
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(),
    );
  }
}
