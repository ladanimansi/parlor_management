import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/appointment_model.dart';
import '../../data/services/appointment_service.dart';

class AppointmentsController extends GetxController {
  final _appointmentService = Get.find<AppointmentService>();
  final appointments = <AppointmentModel>[].obs;
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    ever(_appointmentService.allAppointments, (_) => _filterAppointments());
    _filterAppointments();
  }

  void _filterAppointments() {
    appointments.assignAll(
      _appointmentService.allAppointments
          .where((app) => isSameDay(app.visitingDateTime, selectedDay.value))
          .toList(),
    );
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    selectedDay.value = selected;
    focusedDay.value = focused;
    _filterAppointments();
  }

  void addAppointment(AppointmentModel appointment) {
    _appointmentService.addAppointment(appointment);
  }

  void updateAppointment(AppointmentModel updatedApp) {
    _appointmentService.updateAppointment(updatedApp);
  }

  void deleteAppointment(String id) {
    _appointmentService.deleteAppointment(id);
  }
}
