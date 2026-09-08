import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import '../../routes/app_routes.dart';
import '../services/services_controller.dart';
import 'orders_controller.dart';

class OrderDetailView extends GetView<OrdersController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final initialOrder = Get.arguments as AppointmentModel?;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (initialOrder != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
              tooltip: "Edit Order",
              onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT, arguments: initialOrder),
            ),
          if (initialOrder != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: "Delete Order",
              onPressed: () => _confirmDelete(initialOrder.id),
            ),
        ],
      ),
      body: Obx(() {
        if (initialOrder == null) {
          return const Center(child: Text("Order not found"));
        }

        // Find live order from controller for reactive state updates
        final order = controller.allOrders.firstWhere(
          (o) => o.id == initialOrder.id,
          orElse: () => initialOrder,
        );

        final initials = order.clientName.trim().isNotEmpty
            ? order.clientName.trim()[0].toUpperCase()
            : 'C';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Client & Mobile Info Card
              _buildClientInfoCard(context, order, initials),
              const SizedBox(height: 16),

              // 2. Services Execution Card
              _buildServicesExecutionCard(context, order),
              const SizedBox(height: 16),

              // 3. Product Preparation Workflow Card
              _buildProductPreparationCard(context, order),
              const SizedBox(height: 16),

              // 4. Billing & Payment Management Card
              _buildBillingPaymentCard(context, order),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  // --- CLIENT & MOBILE INFO CARD ---
  Widget _buildClientInfoCard(BuildContext context, AppointmentModel order, String initials) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar Circle
              Container(
                width: 52,
                height: 52,
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
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Client Name & Mobile Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.clientName.trim().isEmpty ? "Walk-in Client" : order.clientName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_android_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.mobileNumber.isEmpty ? "No Mobile Number" : order.mobileNumber,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Booking Type Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
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
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 14),

          // Additional Metadata (Age, Gender, Order Time, Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Time",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(order.bookingDateTime),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Overall Status",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      order.status.tr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if ((order.clientAge != null) || (order.clientGender != null && order.clientGender!.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (order.clientAge != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Chip(
                      avatar: const Icon(Icons.cake_outlined, size: 14, color: AppColors.primary),
                      label: Text("Age: ${order.clientAge}", style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                if (order.clientGender != null && order.clientGender!.isNotEmpty)
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 14, color: AppColors.secondary),
                    label: Text(order.clientGender!, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- SERVICES EXECUTION CARD ---
  Widget _buildServicesExecutionCard(BuildContext context, AppointmentModel order) {
    final allocs = order.effectiveServiceAllocations;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        "Services & Staff Execution",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {'appointmentId': order.id}),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 14, color: AppColors.primary),
                label: const Text("Allocate Staff", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (allocs.isNotEmpty) ...[
            ...allocs.map((alloc) {
              final hasStaff = alloc.staffName != null && alloc.staffName!.isNotEmpty;

              Color statusBg;
              Color statusColor;
              if (alloc.status == 'Completed') {
                statusBg = Colors.purple.withValues(alpha: 0.1);
                statusColor = Colors.purple.shade700;
              } else if (alloc.status == 'Running') {
                statusBg = Colors.orange.withValues(alpha: 0.1);
                statusColor = Colors.orange.shade800;
              } else {
                statusBg = Colors.blue.withValues(alpha: 0.1);
                statusColor = Colors.blue.shade700;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
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
                            Row(
                              children: [
                                Icon(
                                  hasStaff ? Icons.how_to_reg_outlined : Icons.warning_amber_outlined,
                                  size: 14,
                                  color: hasStaff ? Colors.green.shade700 : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    hasStaff ? "Staff: ${alloc.staffName!}" : "Tap 'Allocate Staff' to assign",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: hasStaff ? Colors.grey.shade700 : Colors.orange.shade800,
                                      fontWeight: hasStaff ? FontWeight.w500 : FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status Action Button
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alloc.status,
                              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (alloc.status == 'Waiting')
                            ElevatedButton.icon(
                              onPressed: hasStaff ? () => controller.startService(order, alloc.serviceId) : null,
                              icon: const Icon(Icons.play_arrow, size: 14, color: Colors.white),
                              label: const Text("Start", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            )
                          else if (alloc.status == 'Running')
                            ElevatedButton.icon(
                              onPressed: () => controller.completeService(order, alloc.serviceId),
                              icon: const Icon(Icons.check, size: 14, color: Colors.white),
                              label: const Text("Finish", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
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
            Text(
              "Services: ${order.serviceName.isEmpty ? "General Service" : order.serviceName}",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  // --- PRODUCT PREPARATION CARD ---
  Widget _buildProductPreparationCard(BuildContext context, AppointmentModel order) {
    final firstCategory = order.category.split(',').first.trim();

    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Product Preparation",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Configure required products for services",
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Get.toNamed(Routes.ORDER_PREPARATION, arguments: {
                'category': firstCategory.isEmpty ? 'All' : firstCategory,
                'appointmentId': order.id,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Prepare", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- BILLING & PAYMENT MANAGEMENT CARD ---
  Widget _buildBillingPaymentCard(BuildContext context, AppointmentModel order) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.receipt_outlined, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Billing & Payment Details",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _showAddServiceDialog(context, order),
                icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                label: const Text("+ Extra Service", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.6),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Bill Amount", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    "₹${order.amount.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.accent),
                  ),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Payment Status", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _showPaymentPicker(order),
                    child: _buildPaymentBadge(order),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadge(AppointmentModel order) {
    Color badgeColor;
    if (order.paymentStatus == 'Paid') {
      badgeColor = Colors.green.shade700;
    } else if (order.paymentStatus == 'Partial') {
      badgeColor = Colors.orange.shade800;
    } else {
      badgeColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 13, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            order.paymentStatus,
            style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 14, color: badgeColor),
        ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Collect Payment (Total Bill: ₹${order.amount.toStringAsFixed(0)})",
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
              final isSelected = order.paymentStatus == status;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(Icons.payment, color: statusColor, size: 18),
                ),
                title: Text(status, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Add Extra Service to Current Bill",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            Flexible(
              child: Obx(() {
                final services = servicesController.allServices;
                if (services.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No services available"),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 18),
                      ),
                      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Category: ${service.category} • ₹${service.price.toStringAsFixed(0)}"),
                      trailing: const Icon(Icons.add_circle, color: AppColors.primary),
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

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: Text("confirm_delete".tr),
        content: const Text("Are you sure you want to delete this order?"),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)),
          TextButton(
            onPressed: () {
              controller.deleteAppointment(id);
              Get.back(); // close dialog
              Get.back(); // close order detail view
            },
            child: Text("delete".tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
