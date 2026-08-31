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
    // Services first
    Get.put(AppointmentService());
    Get.put(StaffService());
    Get.put(CustomerService());

    // Controllers
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<ServicesController>(() => ServicesController());
    Get.lazyPut<MenuController>(() => MenuController());
    Get.put(ProductCategoryController(), permanent: true);
    Get.put(ProductItemController(), permanent: true);
  }
}
