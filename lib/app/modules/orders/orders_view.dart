import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import '../../routes/app_routes.dart';
import '../services/services_controller.dart';
import 'orders_controller.dart';

class OrdersView extends GetView<OrdersController> {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "orders".tr,
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
                  hintText: "Search client name, mobile or category...",
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

          // Orders list
          Expanded(
            child: Obx(() {
              final orders = controller.filteredOrders;
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Client name and Status Badge
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
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showPaymentPicker(order),
                                    child: _buildPaymentBadge(order),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _showStatusPicker(order),
                                    child: _buildStatusBadge(order),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 4),

                          // Demographic information (Gender, Age, Remarks)
                          if ((order.clientAge != null) || 
                              (order.clientGender != null && order.clientGender!.isNotEmpty) || 
                              (order.clientOtherInfo != null && order.clientOtherInfo!.isNotEmpty))
                            Text(
                              "${order.clientGender ?? ''}${order.clientAge != null ? ', ${order.clientAge} yrs' : ''}${order.clientOtherInfo != null && order.clientOtherInfo!.isNotEmpty ? ' (${order.clientOtherInfo})' : ''}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontStyle: FontStyle.italic),
                            ),

                          const SizedBox(height: 8),

                          // Mobile Number & Date Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (order.mobileNumber.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      order.mobileNumber,
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                  ],
                                )
                              else
                                const SizedBox.shrink(),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Products Selection Display
                          if (order.selectedProducts != null && order.selectedProducts!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "Products: ${order.selectedProducts}",
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 12),

                          // Service-wise Execution Checklist (Stage 3)
                          if (order.serviceAllocations.isNotEmpty) ...[
                            Text(
                              "Execution Status",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...order.serviceAllocations.map((alloc) {
                              Color stateColor;
                              if (alloc.status == 'Completed') {
                                stateColor = Colors.purple;
                              } else if (alloc.status == 'Running') {
                                stateColor = Colors.orange;
                              } else {
                                stateColor = Colors.blue;
                              }
                              
                              final hasStaff = alloc.staffName != null && alloc.staffName!.isNotEmpty;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade100),
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
                                            const SizedBox(height: 2),
                                            Text(
                                              hasStaff ? "Staff: ${alloc.staffName}" : "Staff: Unallocated",
                                              style: TextStyle(
                                                fontSize: 12, 
                                                color: hasStaff ? Colors.grey.shade700 : Colors.red.shade700,
                                                fontWeight: hasStaff ? FontWeight.normal : FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: stateColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              alloc.status,
                                              style: TextStyle(color: stateColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Transition Buttons
                                          if (alloc.status == 'Waiting')
                                            IconButton(
                                              icon: const Icon(Icons.play_circle_fill_outlined, color: Colors.green, size: 24),
                                              onPressed: hasStaff 
                                                  ? () => controller.startService(order, alloc.serviceId)
                                                  : null,
                                              tooltip: hasStaff ? "Start Service" : "Allocate staff first",
                                            )
                                          else if (alloc.status == 'Running')
                                            IconButton(
                                              icon: const Icon(Icons.check_circle, color: Colors.purple, size: 24),
                                              onPressed: () => controller.completeService(order, alloc.serviceId),
                                              tooltip: "Complete Service",
                                            )
                                          else
                                            const Icon(Icons.check_circle, color: Colors.purple, size: 22),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ] else ...[
                            // Fallback Services / Prepared Items Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.spa_outlined, size: 18, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Services / Items",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order.serviceName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "₹${order.amount.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 10),
                          
                          // Subtotal bill and Real-time order modifiers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Bill Total: ₹${order.amount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.accent,
                                ),
                              ),
                              Row(
                                children: [
                                  // Add Service on-the-fly
                                  TextButton.icon(
                                    onPressed: () => _showAddServiceDialog(context, order),
                                    icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                                    label: const Text(
                                      "Add Service",
                                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  // Payment collection
                                  TextButton.icon(
                                    onPressed: () => _showPaymentPicker(order),
                                    icon: const Icon(Icons.payment, size: 14, color: Colors.green),
                                    label: const Text(
                                      "Collect Payment",
                                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
                          const Divider(height: 1, thickness: 0.5),
                          const SizedBox(height: 12),

                          // Action Buttons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Go to Preparation Button
                              TextButton.icon(
                                onPressed: () {
                                  final firstCategory = order.category.split(',').first.trim();
                                  Get.toNamed(Routes.ORDER_PREPARATION, arguments: {
                                    'category': firstCategory.isEmpty ? 'All' : firstCategory,
                                    'appointmentId': order.id,
                                  });
                                },
                                icon: const Icon(Icons.assignment_outlined, size: 16, color: AppColors.primary),
                                label: Text(
                                  "preparation".tr,
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Go to Allocation
                              TextButton.icon(
                                onPressed: () {
                                  Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {
                                    'appointmentId': order.id,
                                  });
                                },
                                icon: const Icon(Icons.people_outline, size: 16, color: AppColors.secondary),
                                label: const Text(
                                  "Allocation",
                                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Edit Order Button
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT, arguments: order),
                              ),
                              
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _confirmDelete(order.id),
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

  Widget _buildPaymentBadge(AppointmentModel order) {
    Color badgeColor;
    if (order.paymentStatus == 'Paid') {
      badgeColor = Colors.green;
    } else if (order.paymentStatus == 'Partial') {
      badgeColor = Colors.orange;
    } else {
      badgeColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 0.8),
      ),
      child: Text(
        order.paymentStatus,
        style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showPaymentPicker(AppointmentModel order) {
    final paymentStatuses = ['Pending', 'Partial', 'Paid'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Update Payment Status (Bill: ₹${order.amount.toStringAsFixed(0)})",
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            ...paymentStatuses.map((status) {
              Color statusColor;
              if (status == 'Paid') {
                statusColor = Colors.green;
              } else if (status == 'Partial') {
                statusColor = Colors.orange;
              } else {
                statusColor = Colors.red;
              }
              return ListTile(
                leading: Icon(Icons.payment, color: statusColor),
                title: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: order.paymentStatus == status ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  controller.updatePaymentStatus(order, status);
                  Get.back();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showAddServiceDialog(BuildContext context, AppointmentModel order) {
    final servicesController = Get.find<ServicesController>();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Add Extra Service to Order",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            Flexible(
              child: Obx(() {
                final services = servicesController.allServices;
                if (services.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No services available"),
                  ));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Category: ${service.category} | Price: ₹${service.price}"),
                      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onTap: () {
                        controller.addServiceToOrder(order, service);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showStatusPicker(AppointmentModel appointment) {
    final statuses = ['Inquiry', 'Confirm', 'InProgress', 'Completed', 'Cancelled'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "status".tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            ...statuses.map((s) {
              final dummyApp = AppointmentModel(
                id: '',
                clientName: '',
                mobileNumber: '',
                serviceName: '',
                category: '',
                visitingDateTime: DateTime.now(),
                bookingDateTime: DateTime.now(),
                status: s,
                amount: 0,
              );
              return ListTile(
                leading: Icon(Icons.circle, color: dummyApp.statusColor, size: 16),
                title: Text(dummyApp.statusKey.tr),
                trailing: appointment.status == s ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () {
                  Get.back();
                  controller.updateAppointment(appointment.copyWith(status: s));
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentModel appointment) {
    final color = appointment.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        appointment.statusKey.tr,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: Text("confirm_delete".tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)),
          TextButton(
            onPressed: () {
              controller.deleteAppointment(id);
              Get.back();
            },
            child: Text("delete".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
