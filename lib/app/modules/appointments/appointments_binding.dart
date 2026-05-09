import 'package:get/get.dart';
import 'appointments_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuController>(() => MenuController());
  }
}
