import '../models/appointment_model.dart';
import '../models/customer_model.dart';

class MockHistorySeed {
  static const String testMobile = '';
  static const String testClientName = '';

  static CustomerModel getTestCustomer() {
    return CustomerModel(
      id: '',
      name: '',
      mobileNumber: '',
    );
  }

  static List<AppointmentModel> getTestHistoryAppointments() {
    return [];
  }
}
