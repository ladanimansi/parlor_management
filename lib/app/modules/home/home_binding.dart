import 'package:get/get.dart';
import '../../data/services/appointment_service.dart';
import '../home/home_controller.dart';
import '../dashboard/dashboard_controller.dart';
import '../services/services_controller.dart';
import '../appointments/appointments_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Services first
    Get.put(AppointmentService());

    // Controllers
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
    Get.lazyPut<ServicesController>(
      () => ServicesController(),
    );
    Get.lazyPut<AppointmentsController>(
      () => AppointmentsController(),
    );
  }
}
