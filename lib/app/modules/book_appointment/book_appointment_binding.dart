import 'package:get/get.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/customer_service.dart';
import '../../data/services/staff_service.dart';
import '../product_category/product_category_controller.dart';
import '../product_item/product_item_controller.dart';
import '../services/services_controller.dart';
import 'book_appointment_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core services are available
    if (!Get.isRegistered<AppointmentService>()) {
      Get.put(AppointmentService(), permanent: true);
    }
    if (!Get.isRegistered<CustomerService>()) {
      Get.put(CustomerService(), permanent: true);
    }
    if (!Get.isRegistered<StaffService>()) {
      Get.put(StaffService(), permanent: true);
    }

    // Ensure controllers are available
    if (!Get.isRegistered<ProductCategoryController>()) {
      Get.put<ProductCategoryController>(ProductCategoryController(), permanent: false);
    }
    if (!Get.isRegistered<ProductItemController>()) {
      Get.put<ProductItemController>(ProductItemController(), permanent: false);
    }
    if (!Get.isRegistered<ServicesController>()) {
      Get.lazyPut<ServicesController>(() => ServicesController(), fenix: true);
    }

    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(),
    );
  }
}
