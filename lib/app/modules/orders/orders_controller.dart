import 'package:get/get.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/service_model.dart';
import '../../data/services/appointment_service.dart';

class OrdersController extends GetxController {
  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  final searchQuery = ''.obs;
  final isSearchOpen = false.obs;
  final activeTab = 'All'.obs; // 'All', 'InProgress', 'PendingAllocation', 'Completed', 'Waiting', 'Confirm', 'Cancelled'
  final selectedServiceFilter = 'All'.obs;

  void toggleSearch() {
    isSearchOpen.value = !isSearchOpen.value;
    if (!isSearchOpen.value) {
      searchQuery.value = '';
    }
  }

  bool get hasActiveFilters =>
      activeTab.value != 'All' ||
      selectedServiceFilter.value != 'All' ||
      searchQuery.value.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (activeTab.value != 'All') count++;
    if (selectedServiceFilter.value != 'All') count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  List<String> get availableServices {
    final set = <String>{'All'};
    for (final order in allOrders) {
      if (order.serviceName.isNotEmpty) {
        final parts = order.serviceName.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        set.addAll(parts);
      }
    }
    return set.toList();
  }

  void resetAllFilters() {
    activeTab.value = 'All';
    selectedServiceFilter.value = 'All';
    searchQuery.value = '';
  }

  List<AppointmentModel> get allOrders => _appointmentService.allAppointments;

  List<AppointmentModel> get filteredOrders {
    final query = searchQuery.value.toLowerCase().trim();
    final tab = activeTab.value;
    final serviceFilter = selectedServiceFilter.value;

    var list = List<AppointmentModel>.from(_appointmentService.allAppointments);
    list.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));

    // 1. Status / Tab Filter
    if (tab == 'InProgress') {
      list = list.where((o) => o.status == 'InProgress' || o.status == 'Confirm' || o.serviceAllocations.any((sa) => sa.status == 'Running')).toList();
    } else if (tab == 'PendingAllocation') {
      list = list.where((o) {
        if (o.serviceAllocations.isNotEmpty) {
          return o.serviceAllocations.any((sa) => sa.staffId == null || sa.staffId!.isEmpty);
        }
        return o.allocatedStaffId == null || o.allocatedStaffId!.isEmpty;
      }).toList();
    } else if (tab == 'Completed') {
      list = list.where((o) => o.status == 'Completed').toList();
    } else if (tab == 'Waiting') {
      list = list.where((o) => o.status == 'Waiting').toList();
    } else if (tab == 'Cancelled') {
      list = list.where((o) => o.status == 'Cancelled').toList();
    } else if (tab == 'Confirm') {
      list = list.where((o) => o.status == 'Confirm').toList();
    }

    // 2. Service Filter
    if (serviceFilter != 'All') {
      list = list.where((o) => o.serviceName.toLowerCase().contains(serviceFilter.toLowerCase())).toList();
    }

    // 3. Search Query
    if (query.isNotEmpty) {
      list = list.where((app) {
        final matchesClient = app.clientName.toLowerCase().contains(query);
        final matchesMobile = app.mobileNumber.contains(query);
        final matchesCategory = app.category.toLowerCase().contains(query);
        final matchesServices = app.serviceName.toLowerCase().contains(query);
        return matchesClient || matchesMobile || matchesCategory || matchesServices;
      }).toList();
    }

    return list;
  }

  void updateAppointment(AppointmentModel app) {
    _appointmentService.updateAppointment(app);
  }

  void deleteAppointment(String id) {
    _appointmentService.deleteAppointment(id);
  }

  // --- Stage 3: Service-wise Status Transitions & Simulated SMS Notifications ---
  
  void acceptService(AppointmentModel order, String serviceId) {
    final updatedAllocations = order.serviceAllocations.map((sa) {
      if (sa.serviceId == serviceId) {
        return sa.copyWith(status: 'Waiting');
      }
      return sa;
    }).toList();

    final alloc = order.effectiveServiceAllocations.firstWhereOrNull((sa) => sa.serviceId == serviceId);
    final hasStaff = (alloc?.staffId != null && alloc!.staffId!.isNotEmpty) ||
        (order.allocatedStaffId != null && order.allocatedStaffId!.isNotEmpty);

    // Order status can move to InProgress ONLY if staff is allocated
    String overallStatus = order.status;
    if (hasStaff && (overallStatus == 'Inquiry' || overallStatus == 'Confirm' || overallStatus == 'Waiting')) {
      overallStatus = 'InProgress';
    }

    final updatedOrder = order.copyWith(
      status: overallStatus,
      serviceAllocations: updatedAllocations,
    );
    _appointmentService.updateAppointment(updatedOrder);
    Get.snackbar("Service Accepted", "Service status changed to Waiting");
  }

  void startService(AppointmentModel order, String serviceId) {
    final alloc = order.effectiveServiceAllocations.firstWhereOrNull((sa) => sa.serviceId == serviceId);
    final hasStaff = (alloc?.staffId != null && alloc!.staffId!.isNotEmpty) ||
        (order.allocatedStaffId != null && order.allocatedStaffId!.isNotEmpty);

    if (!hasStaff) {
      Get.snackbar(
        "Staff Allocation Required",
        "Cannot start service! Please allocate staff first.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    String serviceName = '';
    String staffName = '';
    
    final updatedAllocations = order.serviceAllocations.map((sa) {
      if (sa.serviceId == serviceId) {
        serviceName = sa.serviceName;
        staffName = sa.staffName ?? 'Staff';
        return sa.copyWith(status: 'Running');
      }
      return sa;
    }).toList();

    String overallStatus = order.status;
    if (overallStatus == 'Confirm' || overallStatus == 'Waiting') {
      overallStatus = 'InProgress';
    }

    final updatedOrder = order.copyWith(
      status: overallStatus,
      serviceAllocations: updatedAllocations,
    );
    _appointmentService.updateAppointment(updatedOrder);

    // Simulated customer notification
    if (order.mobileNumber.isNotEmpty) {
      Get.snackbar(
        "SMS Notification Sent", 
        "To ${order.clientName} (${order.mobileNumber}): Your service '$serviceName' has started with $staffName!",
        duration: const Duration(seconds: 4),
      );
    }
  }

  void completeService(AppointmentModel order, String serviceId) {
    String serviceName = '';
    
    final updatedAllocations = order.serviceAllocations.map((sa) {
      if (sa.serviceId == serviceId) {
        serviceName = sa.serviceName;
        return sa.copyWith(status: 'Completed');
      }
      return sa;
    }).toList();

    // Check if all services are completed
    final allCompleted = updatedAllocations.every((sa) => sa.status == 'Completed');
    String overallStatus = order.status;
    if (allCompleted) {
      overallStatus = 'Completed';
    }

    final updatedOrder = order.copyWith(
      status: overallStatus,
      serviceAllocations: updatedAllocations,
    );
    _appointmentService.updateAppointment(updatedOrder);

    // Simulated customer notification
    if (order.mobileNumber.isNotEmpty) {
      Get.snackbar(
        "SMS Notification Sent", 
        "To ${order.clientName} (${order.mobileNumber}): Your service '$serviceName' has been completed. Thank you!",
        duration: const Duration(seconds: 4),
      );
    }

    if (allCompleted) {
      Get.snackbar(
        "All Services Completed", 
        "Order execution status changed to Completed. Please manage separate Billing.",
        duration: const Duration(seconds: 4),
      );
    }
  }

  // --- Stage 3: Dynamic additional services during running order ---
  
  void addServiceToOrder(AppointmentModel order, ServiceModel service) {
    // Append service name
    final newServiceName = order.serviceName.isEmpty 
        ? service.name 
        : "${order.serviceName}, ${service.name}";
        
    // Append category
    final currentCats = order.category.split(',').map((e) => e.trim()).toList();
    if (!currentCats.contains(service.category)) {
      currentCats.add(service.category);
    }
    final newCategory = currentCats.join(', ');

    // Add price
    final newAmount = order.amount + service.price;

    // Build new allocation item
    final newAlloc = ServiceItemAllocation(
      serviceId: service.id + "_dyn_" + DateTime.now().millisecondsSinceEpoch.toString(),
      serviceName: service.name,
      price: service.price,
      status: 'Waiting', // Starts as waiting for staff selection and accept
    );
    
    final updatedAllocations = List<ServiceItemAllocation>.from(order.serviceAllocations)
      ..add(newAlloc);

    final updatedOrder = order.copyWith(
      serviceName: newServiceName,
      category: newCategory,
      amount: newAmount,
      serviceAllocations: updatedAllocations,
    );

    _appointmentService.updateAppointment(updatedOrder);
    Get.snackbar("Service Added", "'${service.name}' added to current bill. Amount updated to ₹$newAmount.");
  }

  // --- Stage 4: Billing management ---
  
  void updatePaymentStatus(AppointmentModel order, String paymentStatus) {
    final updatedOrder = order.copyWith(paymentStatus: paymentStatus);
    _appointmentService.updateAppointment(updatedOrder);

    if (paymentStatus == 'Paid') {
      Get.snackbar(
        "Payment Collected", 
        "Full payment received. Order for ${order.clientName} has been closed successfully.",
        duration: const Duration(seconds: 3),
      );
    } else {
      Get.snackbar(
        "Payment Updated", 
        "Payment status changed to $paymentStatus.",
        duration: const Duration(seconds: 3),
      );
    }
  }
}
