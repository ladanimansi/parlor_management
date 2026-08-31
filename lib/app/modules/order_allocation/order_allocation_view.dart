import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/staff_model.dart';
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
    final allocations = order.serviceAllocations;
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

                        Text(
                          "Select Staff for '${alloc.serviceName}':",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 10),

                        // Staff Selection Cards List
                        Column(
                          children: controller.allStaff.map((staff) {
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
                                    color: isAssigned ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isAssigned ? AppColors.primary : Colors.grey.shade200,
                                      width: isAssigned ? 1.8 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: isAssigned ? AppColors.primary : Colors.grey.shade200,
                                        child: Text(
                                          staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                                          style: TextStyle(
                                            color: isAssigned ? Colors.white : Colors.black87,
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
                                                Text(
                                                  staff.name,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: isAssigned ? AppColors.primary : Colors.black87,
                                                  ),
                                                ),
                                                if (isSpecialized) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Row(
                                                      children: const [
                                                        Icon(Icons.star, size: 10, color: Colors.amber),
                                                        SizedBox(width: 2),
                                                        Text("Specialist", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: staff.isAvailable ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
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
                        ),
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
        title: Text(
          "Staff Allocation Directory",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: "Search client, mobile, service or staff...",
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Filter Chips Row
                Obx(() {
                  final active = controller.activeFilter.value;
                  final filters = ['All', 'Pending', 'Allocated'];

                  return Row(
                    children: filters.map((f) {
                      final isSelected = active == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(f, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                          ),
                          onSelected: (_) => controller.activeFilter.value = f,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: Obx(() {
              final orders = controller.filteredOrders;
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        "No orders found",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final allocs = order.serviceAllocations;
                  final assignedCount = allocs.where((a) => a.staffId != null && a.staffId!.isNotEmpty).length;
                  final isFullyAllocated = allocs.isNotEmpty && assignedCount == allocs.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.clientName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isFullyAllocated ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isFullyAllocated ? "Allocated ($assignedCount/${allocs.length})" : "Pending ($assignedCount/${allocs.length})",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isFullyAllocated ? Colors.green.shade800 : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            order.serviceName.isEmpty ? "Services Pending" : order.serviceName,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => controller.selectOrderForAllocation(order),
                                icon: const Icon(Icons.person_add_alt_1_outlined, size: 14, color: Colors.white),
                                label: const Text("Manage Staff", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
