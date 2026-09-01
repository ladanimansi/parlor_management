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
  final serviceFilterMap = <String, String>{}.obs; // serviceId -> filter ('all', 'specialists', 'available')

  List<StaffModel> get allStaff => _staffService.allStaff;

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
    final allocs = order.effectiveServiceAllocations;
    return allocs.any((sa) => sa.staffId == null || sa.staffId!.isEmpty);
  }

  List<StaffModel> getMatchingStaffForService(String serviceName) {
    try {
      final sNameLower = serviceName.toLowerCase().trim();
      String serviceCategory = '';

      try {
        final servicesController = Get.find<ServicesController>();
        final service = servicesController.allServices.firstWhereOrNull(
          (s) => s.name.toLowerCase().trim() == sNameLower,
        );
        if (service != null) {
          serviceCategory = service.category.toLowerCase().trim();
        }
      } catch (_) {}

      final matching = allStaff.where((staff) {
        final specs = staff.specialties.map((s) => s.toLowerCase().trim()).toList();

        // Direct specialty match (e.g. staff specialty "Facial" matches serviceName "Facial")
        final directMatch = specs.any((spec) => sNameLower.contains(spec) || spec.contains(sNameLower));

        // Service Category match (e.g. staff specialty "Skin Care" matches serviceCategory "Skin Care")
        final categoryMatch = serviceCategory.isNotEmpty &&
            specs.any((spec) => serviceCategory.contains(spec) || spec.contains(serviceCategory));

        return directMatch || categoryMatch;
      }).toList();

      return matching;
    } catch (_) {
      return allStaff;
    }
  }

  void setServiceFilter(String serviceId, String filter) {
    serviceFilterMap[serviceId] = filter;
  }

  String getServiceFilter(String serviceId) {
    return serviceFilterMap[serviceId] ?? 'all';
  }

  List<StaffModel> getRankedStaffForService(String serviceId, String serviceName) {
    final matchingStaff = getMatchingStaffForService(serviceName);
    final filter = getServiceFilter(serviceId);

    var list = List<StaffModel>.from(allStaff);

    // Apply active filter chip
    if (filter == 'specialists') {
      if (matchingStaff.isNotEmpty) {
        list = matchingStaff;
      }
    } else if (filter == 'available') {
      list = list.where((s) => s.isAvailable).toList();
    }

    // Rank staff: Available + Specialist > Available > Specialist > Others
    list.sort((a, b) {
      final aSpecialist = matchingStaff.any((m) => m.id == a.id);
      final bSpecialist = matchingStaff.any((m) => m.id == b.id);

      int scoreA = (a.isAvailable ? 2 : 0) + (aSpecialist ? 1 : 0);
      int scoreB = (b.isAvailable ? 2 : 0) + (bSpecialist ? 1 : 0);

      return scoreB.compareTo(scoreA);
    });

    return list;
  }

  void selectOrderForAllocation(AppointmentModel? order) {
    selectedOrder.value = order;
  }

  void allocateStaffToService(AppointmentModel order, String serviceId, StaffModel? staff) {
    final currentAllocations = order.effectiveServiceAllocations;

    final updatedAllocations = currentAllocations.map((alloc) {
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

    final staffIds = updatedAllocations
        .map((sa) => sa.staffId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .join(', ');

    final updatedApp = order.copyWith(
      allocatedStaffId: staffIds.isEmpty ? null : staffIds,
      allocatedStaffName: staffNames.isEmpty ? null : staffNames,
      serviceAllocations: updatedAllocations,
    );

    _appointmentService.updateAppointment(updatedApp);
    if (selectedOrder.value?.id == order.id) {
      selectedOrder.value = updatedApp;
    }
  }

  void autoAllocateRecommendedStaff(AppointmentModel order) {
    final allocations = order.effectiveServiceAllocations;
    if (allocations.isEmpty) return;

    final updatedAllocations = allocations.map((alloc) {
      if (alloc.staffId == null || alloc.staffId!.isEmpty) {
        final matches = getMatchingStaffForService(alloc.serviceName);
        final availableMatches = matches.where((s) => s.isAvailable).toList();

        StaffModel? selectedStaff;
        if (availableMatches.isNotEmpty) {
          selectedStaff = availableMatches.first;
        } else if (matches.isNotEmpty) {
          selectedStaff = matches.first;
        } else {
          final allAvailable = allStaff.where((s) => s.isAvailable).toList();
          if (allAvailable.isNotEmpty) {
            selectedStaff = allAvailable.first;
          } else if (allStaff.isNotEmpty) {
            selectedStaff = allStaff.first;
          }
        }

        if (selectedStaff != null) {
          return alloc.copyWith(
            staffId: selectedStaff.id,
            staffName: selectedStaff.name,
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

    final staffIds = updatedAllocations
        .map((sa) => sa.staffId)
        .where((id) => id != null && id.isNotEmpty)
        .toSet()
        .join(', ');

    final updatedApp = order.copyWith(
      allocatedStaffId: staffIds.isEmpty ? null : staffIds,
      allocatedStaffName: staffNames.isEmpty ? null : staffNames,
      serviceAllocations: updatedAllocations,
    );

    _appointmentService.updateAppointment(updatedApp);
    selectedOrder.value = updatedApp;

    Get.snackbar("Auto-Allocated", "Specialized staff matched automatically for all services!");
  }
}
