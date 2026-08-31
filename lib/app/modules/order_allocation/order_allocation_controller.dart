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
  final activeFilter = 'All'.obs; // 'All', 'Pending', 'Allocated'
  final selectedOrder = Rxn<AppointmentModel>();

  List<StaffModel> get allStaff => _staffService.allStaff.where((s) => s.status).toList();

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
  }

  void _handleArguments() {
    final args = Get.arguments;
    String? targetId;
    if (args is Map) {
      targetId = args['appointmentId'];
    } else if (args is String) {
      targetId = args;
    }

    if (targetId != null) {
      final orderIndex = allOrders.indexWhere((app) => app.id == targetId);
      if (orderIndex != -1) {
        selectedOrder.value = allOrders[orderIndex];
      }
    }
  }

  List<AppointmentModel> get allOrders => _appointmentService.allAppointments;

  List<AppointmentModel> get filteredOrders {
    final query = searchQuery.value.toLowerCase().trim();
    final filter = activeFilter.value;
    
    var list = List<AppointmentModel>.from(_appointmentService.allAppointments);
    list.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    if (filter == 'Pending') {
      list = list.where((o) => _isOrderPendingAllocation(o)).toList();
    } else if (filter == 'Allocated') {
      list = list.where((o) => !_isOrderPendingAllocation(o)).toList();
    }

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

  bool _isOrderPendingAllocation(AppointmentModel order) {
    if (order.serviceAllocations.isNotEmpty) {
      return order.serviceAllocations.any((sa) => sa.staffId == null || sa.staffId!.isEmpty);
    }
    return order.allocatedStaffId == null || order.allocatedStaffId!.isEmpty;
  }

  List<StaffModel> getMatchingStaffForService(String serviceName) {
    try {
      final servicesController = Get.find<ServicesController>();
      final service = servicesController.allServices.firstWhereOrNull(
        (s) => s.name.toLowerCase() == serviceName.toLowerCase()
      );
      if (service == null) return allStaff;
      
      final matching = allStaff.where((staff) {
        return staff.specialties.any((spec) => spec.toLowerCase() == service.category.toLowerCase());
      }).toList();

      if (matching.isEmpty) return allStaff;
      return matching;
    } catch (_) {
      return allStaff;
    }
  }

  void selectOrderForAllocation(AppointmentModel? order) {
    selectedOrder.value = order;
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
    // Keep live reference in selectedOrder
    if (selectedOrder.value?.id == order.id) {
      selectedOrder.value = updatedApp;
    }
  }

  void autoAllocateRecommendedStaff(AppointmentModel order) {
    if (order.serviceAllocations.isEmpty) return;

    final updatedAllocations = order.serviceAllocations.map((alloc) {
      if (alloc.staffId == null || alloc.staffId!.isEmpty) {
        final matches = getMatchingStaffForService(alloc.serviceName);
        if (matches.isNotEmpty) {
          final recommendedStaff = matches.first;
          return alloc.copyWith(
            staffId: recommendedStaff.id,
            staffName: recommendedStaff.name,
          );
        }
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
    selectedOrder.value = updatedApp;

    Get.snackbar("Auto-Allocated", "Specialized staff matched automatically for all services!");
  }
}
