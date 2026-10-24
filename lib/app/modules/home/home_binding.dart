import 'package:get/get.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/staff_service.dart';
import '../../data/services/customer_service.dart';
import '../home/home_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../services/services_controller.dart';
import '../appointments/appointments_controller.dart';
import '../product_category/product_category_controller.dart';
import '../product_item/product_item_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services must be permanent so real-time streams and state survive screen navigation
    if (!Get.isRegistered<AppointmentService>()) {
      Get.put(AppointmentService(), permanent: true);
    }
    if (!Get.isRegistered<StaffService>()) {
      Get.put(StaffService(), permanent: true);
    }
    if (!Get.isRegistered<CustomerService>()) {
      Get.put(CustomerService(), permanent: true);
    }

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);
    Get.lazyPut<ServicesController>(() => ServicesController(), fenix: true);
    Get.lazyPut<MenuController>(() => MenuController(), fenix: true);
    Get.put(ProductCategoryController(), permanent: true);
    Get.put(ProductItemController(), permanent: true);
  }
}
