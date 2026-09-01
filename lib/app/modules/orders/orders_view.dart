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
          "Live Orders",
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
            tooltip: "New Order",
            onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Search & Filter Bar Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: "Search client, phone or service...",
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Status Filter Tab Chips
                Obx(() {
                  final currentTab = controller.activeTab.value;
                  final tabs = [
                    {'key': 'All', 'label': 'All Orders'},
                    {'key': 'InProgress', 'label': 'In Progress'},
                    {'key': 'PendingAllocation', 'label': 'Pending Staff'},
                    {'key': 'Completed', 'label': 'Completed'},
                  ];

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tabs.map((t) {
                        final key = t['key']!;
                        final label = t['label']!;
                        final isSelected = currentTab == key;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.backgroundLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              ),
                            ),
                            onSelected: (_) => controller.activeTab.value = key,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Live Orders List
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
                        "No live orders found",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Create Walk-in Order"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildModernOrderCard(context, order);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Walk-in Order", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- MODERN STREAMLINED ORDER CARD ---
  Widget _buildModernOrderCard(BuildContext context, AppointmentModel order) {
    final initials = order.clientName.isNotEmpty ? order.clientName[0].toUpperCase() : 'C';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, Client Name, Booking Type & More Options Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Text(
                          initials,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.clientName,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                             Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                if (order.mobileNumber.isNotEmpty) ...[
                                  Text(
                                    order.mobileNumber,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  Text("•", style: TextStyle(color: Colors.grey.shade400)),
                                ],
                                Text(
                                  DateFormat('hh:mm a').format(order.bookingDateTime),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        order.bookingType.tr,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (val) {
                        if (val == 'prepare') {
                          final firstCategory = order.category.split(',').first.trim();
                          Get.toNamed(Routes.ORDER_PREPARATION, arguments: {
                            'category': firstCategory.isEmpty ? 'All' : firstCategory,
                            'appointmentId': order.id,
                          });
                        } else if (val == 'allocate') {
                          Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {'appointmentId': order.id});
                        } else if (val == 'edit') {
                          Get.toNamed(Routes.BOOK_APPOINTMENT, arguments: order);
                        } else if (val == 'delete') {
                          _confirmDelete(order.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'allocate',
                          child: ListTile(
                            leading: Icon(Icons.person_add_alt_1_outlined, color: AppColors.secondary, size: 20),
                            title: Text('Allocate Staff'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'prepare',
                          child: ListTile(
                            leading: Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                            title: Text('Prepare Products'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            title: Text('Edit Order'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            title: Text('Delete Order'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // Services & Live Execution Progress List
            if (order.effectiveServiceAllocations.isNotEmpty) ...[
              Text(
                "Services Execution",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              ...order.effectiveServiceAllocations.map((alloc) {
                final hasStaff = alloc.staffName != null && alloc.staffName!.isNotEmpty;

                Color statusBg;
                Color statusColor;
                if (alloc.status == 'Completed') {
                  statusBg = Colors.purple.withOpacity(0.1);
                  statusColor = Colors.purple;
                } else if (alloc.status == 'Running') {
                  statusBg = Colors.orange.withOpacity(0.1);
                  statusColor = Colors.orange;
                } else {
                  statusBg = Colors.blue.withOpacity(0.1);
                  statusColor = Colors.blue;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    hasStaff ? Icons.person_outline : Icons.warning_amber_outlined,
                                    size: 13,
                                    color: hasStaff ? Colors.grey.shade600 : Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hasStaff ? alloc.staffName! : "Tap 'Allocate Staff' to assign",
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

                        // Action Status Transition Button
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
              // General Services Fallback Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.serviceName.isEmpty ? "General Services" : order.serviceName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {'appointmentId': order.id}),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 14),
                    label: const Text("Allocate Staff"),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 12),

            // Footer Bar: Total Bill, Payment Status Pill & + Add Extra Service Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(
                      "₹${order.amount.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent),
                    ),
                  ],
                ),

                Row(
                  children: [
                    // Payment Status Pill (Clickable)
                    GestureDetector(
                      onTap: () => _showPaymentPicker(order),
                      child: _buildPaymentBadge(order),
                    ),
                    const SizedBox(width: 8),
                    // Add Extra Service Button
                    OutlinedButton.icon(
                      onPressed: () => _showAddServiceDialog(context, order),
                      icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
                      label: const Text("+ Extra", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            order.paymentStatus,
            style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
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
                  backgroundColor: statusColor.withOpacity(0.1),
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
                        backgroundColor: AppColors.primary.withOpacity(0.1),
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
              Get.back();
            },
            child: Text("delete".tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
