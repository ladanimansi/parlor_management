import 'package:get/get.dart';
import '../models/appointment_model.dart';
import '../repositories/appointment_repository.dart';

class AppointmentService extends GetxService {
  final allAppointments = <AppointmentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  void loadAppointments() {
    allAppointments.assignAll(AppointmentRepository.getInitialAppointments());
  }

  void addAppointment(AppointmentModel appointment) {
    allAppointments.add(appointment);
  }

  void updateAppointment(AppointmentModel updatedApp) {
    final index = allAppointments.indexWhere((app) => app.id == updatedApp.id);
    if (index != -1) {
      allAppointments[index] = updatedApp;
    }
  }

  void deleteAppointment(String id) {
    allAppointments.removeWhere((app) => app.id == id);
  }
}
