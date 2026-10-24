import 'package:get/get.dart';
import '../../data/services/appointment_service.dart';
import 'dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentService>()) {
      Get.put(AppointmentService(), permanent: true);
    }
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
      fenix: true,
    );
  }
}
