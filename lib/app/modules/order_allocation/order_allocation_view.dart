import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import '../../routes/app_routes.dart';
import 'order_allocation_controller.dart';

class OrderAllocationView extends GetView<OrderAllocationController> {
  const OrderAllocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentOrder = controller.selectedOrder.value;
      if (currentOrder != null) {
        return _buildFullPageAllocationScreen(context, currentOrder);
      } else {
        return _buildOrderSelectionListScreen(context);
      }
    });
  }

  // --- FULL PAGE DEDICATED ALLOCATION SCREEN ---
  Widget _buildFullPageAllocationScreen(BuildContext context, AppointmentModel order) {
    final allocations = order.effectiveServiceAllocations;
    final totalServices = allocations.length;
    final assignedCount = allocations.where((a) => a.staffId != null && a.staffId!.isNotEmpty).length;
    final isFullyAllocated = totalServices > 0 && assignedCount == totalServices;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Get.key.currentState?.canPop() ?? false) {
              controller.selectOrderForAllocation(null);
            } else {
              controller.selectOrderForAllocation(null);
            }
          },
        ),
        title: Text(
          "Allocate Staff",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          TextButton.icon(
            onPressed: () => controller.autoAllocateRecommendedStaff(order),
            icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
            label: const Text(
              "Auto-Match",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Client Summary Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.clientName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (order.mobileNumber.isNotEmpty)
                                  Text(
                                    order.mobileNumber,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.bookingType.tr,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFullyAllocated ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isFullyAllocated ? Colors.green : Colors.orange),
                      ),
                      child: Text(
                        isFullyAllocated
                            ? "Fully Allocated ($assignedCount/$totalServices)"
                            : "Allocation Pending ($assignedCount/$totalServices)",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isFullyAllocated ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Services & Staff Assignment List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: allocations.length,
              itemBuilder: (context, index) {
                final alloc = allocations[index];
                final matchingStaff = controller.getMatchingStaffForService(alloc.serviceName);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Header Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.content_cut, color: AppColors.primary, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alloc.serviceName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Price: ₹${alloc.price.toStringAsFixed(0)}",
                                          style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (alloc.staffName != null && alloc.staffName!.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => controller.allocateStaffToService(order, alloc.serviceId, null),
                                icon: const Icon(Icons.close, size: 14, color: Colors.red),
                                label: const Text("Clear", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 12),

                        // Title & Filter Chips Row for Staff Selection
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Staff for '${alloc.serviceName}':",
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                            ),
                            if (matchingStaff.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${matchingStaff.length} Specialists Available",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Staff Selection Filter Segment Chips
                        Obx(() {
                          final currentFilter = controller.getServiceFilter(alloc.serviceId);
                          final availableCount = controller.allStaff.where((s) => s.isAvailable).length;

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: Text(
                                    "👥 All (${controller.allStaff.length})",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: currentFilter == 'all' ? Colors.white : Colors.grey.shade700,
                                    ),
                                  ),
                                  selected: currentFilter == 'all',
                                  selectedColor: AppColors.primary,
                                  backgroundColor: Colors.grey.shade100,
                                  onSelected: (_) => controller.setServiceFilter(alloc.serviceId, 'all'),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                FilterChip(
                                  label: Text(
                                    "⭐ ${alloc.serviceName} (${matchingStaff.length})",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: currentFilter == 'specialists' ? Colors.white : Colors.amber.shade900,
                                    ),
                                  ),
                                  selected: currentFilter == 'specialists',
                                  selectedColor: Colors.amber.shade700,
                                  backgroundColor: Colors.amber.withOpacity(0.12),
                                  onSelected: (_) => controller.setServiceFilter(alloc.serviceId, 'specialists'),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                FilterChip(
                                  label: Text(
                                    "🟢 Available ($availableCount)",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: currentFilter == 'available' ? Colors.white : Colors.green.shade800,
                                    ),
                                  ),
                                  selected: currentFilter == 'available',
                                  selectedColor: Colors.green.shade700,
                                  backgroundColor: Colors.green.withOpacity(0.12),
                                  onSelected: (_) => controller.setServiceFilter(alloc.serviceId, 'available'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Staff Selection Cards List
                        Obx(() {
                          final staffList = controller.getRankedStaffForService(alloc.serviceId, alloc.serviceName);

                          if (staffList.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Text(
                                "No staff matching selected filter",
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            );
                          }

                          return Column(
                            children: staffList.map((staff) {
                              final isAssigned = alloc.staffId == staff.id;
                              final isSpecialized = matchingStaff.any((m) => m.id == staff.id);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (isAssigned) {
                                      controller.allocateStaffToService(order, alloc.serviceId, null);
                                    } else {
                                      controller.allocateStaffToService(order, alloc.serviceId, staff);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isAssigned
                                          ? AppColors.primary.withOpacity(0.08)
                                          : (isSpecialized ? Colors.amber.withOpacity(0.03) : Colors.white),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isAssigned
                                            ? AppColors.primary
                                            : (isSpecialized ? Colors.amber.shade300 : Colors.grey.shade200),
                                        width: isAssigned ? 1.8 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: isAssigned
                                              ? AppColors.primary
                                              : (isSpecialized ? Colors.amber.shade100 : Colors.grey.shade200),
                                          child: Text(
                                            staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                                            style: TextStyle(
                                              color: isAssigned
                                                  ? Colors.white
                                                  : (isSpecialized ? Colors.amber.shade900 : Colors.black87),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      staff.name,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: isAssigned ? AppColors.primary : Colors.black87,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  if (isSpecialized) ...[
                                                    const SizedBox(width: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: const [
                                                          Icon(Icons.star, size: 10, color: Colors.amber),
                                                          SizedBox(width: 2),
                                                          Text(
                                                            "Specialist",
                                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: staff.isAvailable
                                                          ? Colors.green.withOpacity(0.12)
                                                          : Colors.red.withOpacity(0.12),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      staff.isAvailable ? "Free" : "Busy",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: staff.isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                staff.specialties.join(', '),
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          isAssigned ? Icons.check_circle : Icons.radio_button_off,
                                          color: isAssigned ? AppColors.primary : Colors.grey.shade400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Confirmation Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar("Success", "Staff allocations saved!");
                    Get.toNamed(Routes.ORDERS);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Save & Go to Live Orders",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ORDERS SELECTION DIRECTORY SCREEN ---
  Widget _buildOrderSelectionListScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Staff Allocation Directory",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              "Assign & manage staff members for customer orders",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Modern Search Field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => TextField(
                      onChanged: (value) => controller.searchQuery.value = value,
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.searchQuery.value,
                          selection: TextSelection.collapsed(
                            offset: controller.searchQuery.value.length,
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: "Search client name, mobile, service or staff...",
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                        suffixIcon: controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                                onPressed: () => controller.searchQuery.value = '',
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Chips Row with Counters
                Obx(() {
                  final active = controller.activeFilter.value;
                  final allOrders = controller.allOrders;
                  final pendingCount = allOrders.where((o) {
                    final allocs = o.effectiveServiceAllocations;
                    return allocs.any((sa) => sa.staffId == null || sa.staffId!.isEmpty);
                  }).length;
                  final allocatedCount = allOrders.length - pendingCount;

                  final filters = [
                    {'name': 'All', 'count': allOrders.length},
                    {'name': 'Pending', 'count': pendingCount},
                    {'name': 'Allocated', 'count': allocatedCount},
                  ];

                  return Row(
                    children: filters.map((f) {
                      final name = f['name'] as String;
                      final count = f['count'] as int;
                      final isSelected = active == name;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => controller.activeFilter.value = name,
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Professional Orders List
          Expanded(
            child: Obx(() {
              final orders = controller.filteredOrders;
              if (orders.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search_outlined, size: 48, color: AppColors.primary),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No orders found",
                          style: TextStyle(
                            fontSize: 17,
                            color: AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Try searching with a different client name, mobile number, or change your filter selection.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildProfessionalOrderCard(context, order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalOrderCard(BuildContext context, AppointmentModel order) {
    final allocs = order.effectiveServiceAllocations;
    final assignedCount = allocs.where((a) => a.staffId != null && a.staffId!.isNotEmpty).length;
    final totalCount = allocs.length;
    final isFullyAllocated = allocs.isNotEmpty && assignedCount == totalCount;

    final initial = order.clientName.trim().isNotEmpty
        ? order.clientName.trim()[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFullyAllocated
              ? Colors.green.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.selectOrderForAllocation(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Client Avatar + Name & Mobile + Allocation Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Client Avatar Circle
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Client Name & Mobile Number Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.clientName.trim().isEmpty ? "Walk-in Client" : order.clientName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.phone_android_outlined,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  order.mobileNumber.isEmpty ? "No Mobile Number" : order.mobileNumber,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Allocation Status Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFullyAllocated
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFullyAllocated ? Colors.green.shade400 : Colors.orange.shade400,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFullyAllocated ? Icons.check_circle_outline : Icons.pending_actions_outlined,
                          size: 13,
                          color: isFullyAllocated ? Colors.green.shade700 : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFullyAllocated
                              ? "Allocated ($assignedCount/$totalCount)"
                              : "Pending ($assignedCount/$totalCount)",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isFullyAllocated ? Colors.green.shade800 : Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, thickness: 0.6),
              const SizedBox(height: 12),

              // Row 2: Booking Type & Date Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Booking Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.bookingType.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  // Date & Time Stamp
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Services & Staff Allocations Detail Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.design_services_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Services: ${order.serviceName.isEmpty ? "General Service" : order.serviceName}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (allocs.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: allocs.map((sa) {
                          final hasStaff = sa.staffName != null && sa.staffName!.isNotEmpty;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasStaff
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasStaff ? Colors.green.shade300 : Colors.amber.shade400,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  hasStaff ? Icons.how_to_reg_outlined : Icons.person_outline,
                                  size: 12,
                                  color: hasStaff ? Colors.green.shade700 : Colors.amber.shade900,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${sa.serviceName}: ${hasStaff ? sa.staffName : 'Unassigned'}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: hasStaff ? Colors.green.shade900 : Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Button to Manage Allocation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.selectOrderForAllocation(order),
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 16, color: Colors.white),
                  label: const Text(
                    "Manage Staff Allocation",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

