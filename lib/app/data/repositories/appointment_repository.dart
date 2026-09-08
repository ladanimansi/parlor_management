import '../models/appointment_model.dart';
import '../seed/mock_history_seed.dart';

class AppointmentRepository {
  static List<AppointmentModel> getInitialAppointments() {
    return [
      ...MockHistorySeed.getTestHistoryAppointments(),
      AppointmentModel(
        id: '1',
        clientName: 'Reena Patel',
        mobileNumber: '9876543210',
        serviceName: 'Bridal Makeup',
        category: 'Makeup',
        visitingDateTime: DateTime.now().add(const Duration(hours: 2)),
        bookingDateTime: DateTime.now(),
        status: 'Confirm',
        amount: 5000,
        notes: 'Needs heavy base',
      ),
      AppointmentModel(
        id: '2',
        clientName: 'Sonia Shah',
        mobileNumber: '9988776655',
        serviceName: 'Hair Spa',
        category: 'Hair',
        visitingDateTime: DateTime.now().add(const Duration(days: 1)),
        bookingDateTime: DateTime.now(),
        status: 'Inquiry',
        amount: 1200,
      ),
      AppointmentModel(
        id: '3',
        clientName: 'Priya Mehra',
        mobileNumber: '9123456789',
        serviceName: 'Facial',
        category: 'Skin Care',
        visitingDateTime: DateTime.now().add(const Duration(hours: 5)),
        bookingDateTime: DateTime.now(),
        status: 'InProgress',
        amount: 2500,
        referenceBy: 'Instagram',
        allocatedStaffId: 'st_1',
        allocatedStaffName: 'Anjali Sharma',
      ),
    ];
  }
}
