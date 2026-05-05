import 'package:get/get.dart';
import 'book_appointment_controller.dart';

class BookAppointmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookAppointmentController>(
      () => BookAppointmentController(),
    );
  }
}
