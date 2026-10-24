import 'package:get/get.dart';
import '../dashboard/dashboard_controller.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0 && Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().filterAppointments();
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
