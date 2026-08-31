import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import 'order_allocation_controller.dart';


class OrderAllocationView extends GetView<OrderAllocationController> {
  const OrderAllocationView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasOpenedInitialAllocation) {
        final args = Get.arguments;
        String? appointmentId;
        if (args is Map) {
          appointmentId = args['appointmentId'];
        } else if (args is String) {
          appointmentId = args;
        }

        if (appointmentId != null) {
          final orderIndex = controller.allOrders.indexWhere((app) => app.id == appointmentId);
          if (orderIndex != -1) {
            controller.hasOpenedInitialAllocation = true;
            final order = controller.allOrders[orderIndex];
            _showStaffPicker(order);
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "allocation".tr,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // Elegant Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
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
                  hintText: "Search client name, mobile or staff...",
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
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
                      Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey.shade300),
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
                  final hasStaff = order.allocatedStaffName != null && order.allocatedStaffName!.isNotEmpty;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Client name and Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.clientName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Services / Items
                          Text(
                            "Services / Items",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.serviceName.isEmpty ? "No services prepared yet" : order.serviceName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 12),

                          // Allocation Status & Action Button Row
                          if (order.serviceAllocations.isNotEmpty) ...[
                            Text(
                              "Service Allocations",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...order.serviceAllocations.map((alloc) {
                              final hasAllocatedStaff = alloc.staffName != null && alloc.staffName!.isNotEmpty;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alloc.serviceName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              hasAllocatedStaff ? "${'staff'.tr}: ${alloc.staffName}" : "Staff Allocation Remaining",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: hasAllocatedStaff ? Colors.green.shade700 : Colors.orange.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () => _showStaffPickerForService(order, alloc),
                                        icon: const Icon(Icons.person_add_alt_1_outlined, size: 12, color: Colors.white),
                                        label: Text(
                                          hasAllocatedStaff ? "Change" : "Allocate",
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Status Badge
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: hasStaff 
                                          ? Colors.green.withOpacity(0.08) 
                                          : Colors.orange.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: hasStaff 
                                            ? Colors.green.withOpacity(0.3) 
                                            : Colors.orange.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          hasStaff ? Icons.check_circle_outline : Icons.error_outline,
                                          size: 14,
                                          color: hasStaff ? Colors.green.shade700 : Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            hasStaff 
                                                ? "${'staff'.tr}: ${order.allocatedStaffName}"
                                                : "allocation_staff_remaining".tr,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: hasStaff ? Colors.green.shade800 : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Allocate Button
                                ElevatedButton.icon(
                                  onPressed: () => _showStaffPicker(order),
                                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 14, color: Colors.white),
                                  label: Text(
                                    hasStaff ? "change_staff".tr : "allocate_staff".tr,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  void _showStaffPicker(AppointmentModel order) {
    final staffList = controller.getMatchingStaff(order);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "select_staff".tr,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "specialized_staff_preferred".tr,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  if (order.allocatedStaffId != null)
                    TextButton(
                      onPressed: () {
                        controller.allocateStaff(order, null);
                        Get.back();
                        Get.snackbar("success".tr, "allocation_cleared_successfully".tr);
                      },
                      child: Text(
                        "clear_allocation".tr,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: staffList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "no_staff_available".tr,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: staffList.length,
                      itemBuilder: (context, index) {
                        final staff = staffList[index];
                        final isSelected = order.allocatedStaffId == staff.id;
                        final initials = staff.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              initials.length > 2 ? initials.substring(0, 2) : initials,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            staff.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            staff.specialties.join(', '),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                          onTap: () {
                            controller.allocateStaff(order, staff);
                            Get.back();
                            Get.snackbar(
                              "success".tr,
                              "${staff.name} ${'allocated_successfully'.tr}",
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStaffPickerForService(AppointmentModel order, ServiceItemAllocation allocation) {
    final staffList = controller.getMatchingStaffForService(allocation.serviceName);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Assign Staff: ${allocation.serviceName}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Specialized staff for this service are preferred",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (allocation.staffId != null)
                    TextButton(
                      onPressed: () {
                        controller.allocateStaffToService(order, allocation.serviceId, null);
                        Get.back();
                        Get.snackbar("success".tr, "allocation_cleared_successfully".tr);
                      },
                      child: Text(
                        "clear_allocation".tr,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            Flexible(
              child: staffList.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "no_staff_available".tr,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: staffList.length,
                      itemBuilder: (context, index) {
                        final staff = staffList[index];
                        final isSelected = allocation.staffId == staff.id;
                        final initials = staff.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').join().toUpperCase();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              initials.length > 2 ? initials.substring(0, 2) : initials,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            staff.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            staff.specialties.join(', '),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                          onTap: () {
                            controller.allocateStaffToService(order, allocation.serviceId, staff);
                            Get.back();
                            Get.snackbar(
                              "success".tr,
                              "${staff.name} ${'allocated_successfully'.tr}",
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
