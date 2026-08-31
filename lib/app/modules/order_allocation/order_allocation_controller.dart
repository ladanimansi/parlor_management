import 'package:get/get.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/staff_service.dart';
import '../services/services_controller.dart';

class OrderAllocationController extends GetxController {
  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  final StaffService _staffService = Get.find<StaffService>();
  final searchQuery = ''.obs;
  bool hasOpenedInitialAllocation = false;

  List<AppointmentModel> get allOrders => _appointmentService.allAppointments;

  List<AppointmentModel> get filteredOrders {
    final query = searchQuery.value.toLowerCase().trim();
    final list = List<AppointmentModel>.from(_appointmentService.allAppointments);
    list.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    if (query.isEmpty) {
      return list;
    }

    return list.where((app) {
      final matchesClient = app.clientName.toLowerCase().contains(query);
      final matchesMobile = app.mobileNumber.contains(query);
      final matchesCategory = app.category.toLowerCase().contains(query);
      final matchesServices = app.serviceName.toLowerCase().contains(query);
      final matchesStaff = (app.allocatedStaffName ?? '').toLowerCase().contains(query);
      return matchesClient || matchesMobile || matchesCategory || matchesServices || matchesStaff;
    }).toList();
  }

  List<StaffModel> getMatchingStaff(AppointmentModel order) {
    final orderCats = order.category.split(',').map((c) => c.trim().toLowerCase()).toList();
    final matching = _staffService.allStaff.where((staff) {
      if (!staff.status) return false;
      return staff.specialties.any((spec) => orderCats.contains(spec.toLowerCase()));
    }).toList();

    if (matching.isEmpty) {
      return _staffService.allStaff.where((staff) => staff.status).toList();
    }
    return matching;
  }

  List<StaffModel> getMatchingStaffForService(String serviceName) {
    try {
      final servicesController = Get.find<ServicesController>();
      final service = servicesController.allServices.firstWhereOrNull(
        (s) => s.name.toLowerCase() == serviceName.toLowerCase()
      );
      if (service == null) return _staffService.allStaff.where((staff) => staff.status).toList();
      
      final matching = _staffService.allStaff.where((staff) {
        if (!staff.status) return false;
        return staff.specialties.any((spec) => spec.toLowerCase() == service.category.toLowerCase());
      }).toList();

      if (matching.isEmpty) {
        return _staffService.allStaff.where((staff) => staff.status).toList();
      }
      return matching;
    } catch (_) {
      return _staffService.allStaff.where((staff) => staff.status).toList();
    }
  }

  void allocateStaff(AppointmentModel order, StaffModel? staff) {
    // Deprecated for walk-in flow, but kept for compatibility
    final updatedApp = order.copyWith(
      allocatedStaffId: staff?.id,
      allocatedStaffName: staff?.name,
    );
    _appointmentService.updateAppointment(updatedApp);
  }

  void allocateStaffToService(AppointmentModel order, String serviceId, StaffModel? staff) {
    final updatedAllocations = order.serviceAllocations.map((alloc) {
      if (alloc.serviceId == serviceId) {
        return alloc.copyWith(
          staffId: staff?.id,
          staffName: staff?.name,
        );
      }
      return alloc;
    }).toList();

    final staffNames = updatedAllocations
        .map((sa) => sa.staffName)
        .where((name) => name != null && name.isNotEmpty)
        .toSet()
        .join(', ');

    final updatedApp = order.copyWith(
      allocatedStaffName: staffNames.isEmpty ? null : staffNames,
      serviceAllocations: updatedAllocations,
    );
    _appointmentService.updateAppointment(updatedApp);
  }
}
