import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import 'book_appointment_controller.dart';
import 'package:intl/intl.dart';

class BookAppointmentView extends GetView<BookAppointmentController> {
  const BookAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEdit.value
              ? "edit_appointment".tr
              : "book_appointment".tr,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flow Selector (Quick Bill vs. Pre-Booking)
              // Booking Type Selector (Scrollable horizontally)
              Obx(() {
                final selectedType = controller.selectedBookingType.value;
                final types = [
                  {
                    'name': 'Walk in orders',
                    'key': 'walk_in_orders',
                    'icon': Icons.directions_walk,
                  },
                  {
                    'name': 'Advance appoinment',
                    'key': 'advance_appointment',
                    'icon': Icons.calendar_month,
                  },
                  {
                    'name': 'Bridal Orders',
                    'key': 'bridal_orders',
                    'icon': Icons.auto_awesome,
                  },
                  {
                    'name': 'Package',
                    'key': 'package',
                    'icon': Icons.card_membership,
                  },
                  {
                    'name': 'Home service',
                    'key': 'home_service',
                    'icon': Icons.home,
                  },
                ];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "flow_type".tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: types.length,
                        itemBuilder: (context, index) {
                          final type = types[index];
                          final typeName = type['name'] as String;
                          final isSelected = selectedType == typeName;
                          final icon = type['icon'] as IconData;
                          final labelKey = type['key'] as String;

                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                              bottom: 4.0,
                            ),
                            child: GestureDetector(
                              onTap: () =>
                                  controller.selectBookingType(typeName),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade200,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icon,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      labelKey.tr,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                );
              }),
              _buildSectionTitle("client_details".tr),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Customer Status Badge
                    Obx(() {
                      final isNew = controller.isNewCustomer.value;
                      final mobile = controller.mobileNumberController.text;
                      if (mobile.length < 10) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isNew
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isNew ? Colors.orange : Colors.green,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isNew
                                    ? Icons.person_add_outlined
                                    : Icons.check_circle_outline,
                                size: 14,
                                color: isNew
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isNew
                                    ? "New Customer (Registration)"
                                    : "Existing Customer Profile",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isNew
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Obx(
                      () => TextFormField(
                        controller: controller.mobileNumberController,
                        decoration: InputDecoration(
                          labelText: controller.isQuickBill
                              ? "${'mobile_number'.tr} (Optional)"
                              : 'mobile_number'.tr,
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (controller.isQuickBill) return null;
                          return v!.isEmpty ? "required_field".tr : null;
                        },
                      ),
                    ),
                    Obx(
                      () => TextFormField(
                        controller: controller.clientNameController,
                        decoration: InputDecoration(
                          labelText: controller.isQuickBill
                              ? "${'client_name'.tr} (Optional)"
                              : 'client_name'.tr,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (controller.isQuickBill) return null;
                          return v!.isEmpty ? "required_field".tr : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Age & Gender Fields
                    Obx(() {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Age",
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                              keyboardType: TextInputType.number,
                              initialValue:
                                  controller.clientAge.value?.toString() ?? '',
                              onChanged: (val) {
                                controller.clientAge.value = int.tryParse(val);
                              },
                              key: ValueKey(
                                'age_${controller.clientAge.value}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.clientGender.value.isEmpty
                                  ? null
                                  : controller.clientGender.value,
                              hint: const Text("Gender"),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.people_outline),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text("Female"),
                                ),
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text("Male"),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text("Other"),
                                ),
                              ],
                              onChanged: (val) {
                                controller.clientGender.value = val ?? '';
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              // Collapsible History Card
              Obx(() {
                if (controller.previousAppointments.isEmpty) {
                  return const SizedBox.shrink();
                }

                final count = controller.previousAppointments.length;
                final isExpanded = controller.isHistoryExpanded.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                      color: AppColors.primary.withOpacity(0.05),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Icons.history,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              "History ($count previous orders)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            trailing: Icon(
                              isExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: AppColors.primary,
                            ),
                            onTap: () => controller.isHistoryExpanded.toggle(),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: count,
                              itemBuilder: (context, index) {
                                final app =
                                    controller.previousAppointments[index];
                                final dateStr = DateFormat(
                                  'dd MMM yyyy, hh:mm a',
                                ).format(app.bookingDateTime);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: index == count - 1
                                        ? null
                                        : Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade100,
                                              width: 1,
                                            ),
                                          ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              app.serviceName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            "₹${app.amount.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Builder(
                                        builder: (context) {
                                          String staffInfo = 'Staff: ';
                                          if (app
                                              .serviceAllocations
                                              .isNotEmpty) {
                                            staffInfo += app.serviceAllocations
                                                .map(
                                                  (sa) =>
                                                      "${sa.serviceName} (${sa.staffName ?? 'Pending'})",
                                                )
                                                .join(', ');
                                          } else {
                                            staffInfo +=
                                                app.allocatedStaffName ??
                                                'Pending Staff Allocation';
                                          }
                                          return Text(
                                            staffInfo,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  app.bookingType.tr,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                dateStr,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      app.paymentStatus
                                                              .toLowerCase() ==
                                                          'paid'
                                                      ? Colors.green
                                                            .withOpacity(0.1)
                                                      : Colors.orange
                                                            .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  app.paymentStatus,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        app.paymentStatus
                                                                .toLowerCase() ==
                                                            'paid'
                                                        ? Colors.green
                                                        : Colors.orange,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: app.statusColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  app.statusKey.tr,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: app.statusColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }),

              // Visiting Details (Only visible in Pre-Booking mode)
              Obx(() {
                if (controller.isQuickBill) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    _buildSectionTitle("visiting_details".tr),
                    CustomCard(
                      child: Column(
                        children: [
                          _buildDateTimePicker(
                            context,
                            title: "visiting_date_time".tr,
                            dateObs: controller.visitingDate,
                            timeObs: controller.visitingTime,
                            onDateChanged: controller.updateVisitingDate,
                            onTimeChanged: controller.updateVisitingTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              // Order Details (Only visible in Pre-Booking mode)
              Obx(() {
                if (controller.isQuickBill) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    _buildSectionTitle("order_details".tr),
                    CustomCard(
                      child: Column(
                        children: [
                          _buildDateTimePicker(
                            context,
                            title: "order_date_time".tr,
                            dateObs: controller.bookingDate,
                            timeObs: controller.bookingTime,
                            onDateChanged: controller.updateBookingDate,
                            onTimeChanged: controller.updateBookingTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 25),
              _buildSectionTitle("service_details".tr),
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormField<List<String>>(
                      validator: (v) => controller.selectedServices.isEmpty
                          ? "required_field".tr
                          : null,
                      builder: (state) {
                        return Obx(() {
                          final errorText = state.errorText;
                          final hasError =
                              errorText != null &&
                              controller.selectedServices.isEmpty;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () =>
                                    _showMultiSelectServiceDialog(context),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: "service_category".tr,
                                    prefixIcon: const Icon(
                                      Icons.category_outlined,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    errorText: hasError ? errorText : null,
                                  ),
                                  child: controller.selectedServices.isEmpty
                                      ? Text(
                                          "select_service".tr,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 6.0,
                                          runSpacing: -8.0,
                                          children: controller.selectedServices
                                              .map((categoryName) {
                                                return Chip(
                                                  label: Text(
                                                    categoryName,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withOpacity(0.1),
                                                  deleteIcon: const Icon(
                                                    Icons.close,
                                                    size: 14,
                                                  ),
                                                  onDeleted: () =>
                                                      controller.toggleService(
                                                        categoryName,
                                                      ),
                                                  side: BorderSide.none,
                                                );
                                              })
                                              .toList(),
                                        ),
                                ),
                              ),
                            ],
                          );
                        });
                      },
                    ),


                  ],
                ),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("status".tr),
              CustomCard(
                child: Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.statuses.contains(controller.selectedStatus.value)
                        ? controller.selectedStatus.value
                        : 'Waiting',
                    items: controller.statuses.map((s) {
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
                      return DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: dummyApp.statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(dummyApp.statusKey.tr),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) controller.updateStatus(v);
                    },
                    decoration: InputDecoration(
                      labelText: "status".tr,
                      prefixIcon: const Icon(Icons.info_outline, color: AppColors.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   children: [
              //     const SizedBox(height: 25),
              //     _buildSectionTitle("additional_info".tr),
              //     CustomCard(
              //       child: Column(
              //         children: [
              //           TextFormField(
              //             controller: controller.notesController,
              //             decoration: const InputDecoration(
              //               labelText: "Remarks / Special Instructions",
              //               prefixIcon: Icon(Icons.note_alt_outlined),
              //               hintText:
              //                   "Enter any remarks or special requests...",
              //             ),
              //             maxLines: 3,
              //           ),
              //           Obx(() {
              //             if (controller.isQuickBill)
              //               return const SizedBox.shrink();
              //             return Column(
              //               children: [
              //                 const SizedBox(height: 15),
              //                 TextFormField(
              //                   controller: controller.referenceByController,
              //                   decoration: InputDecoration(
              //                     labelText: "reference_by".tr,
              //                     prefixIcon: const Icon(Icons.group_outlined),
              //                     hintText: "e.g., Instagram, Friend, Google",
              //                   ),
              //                 ),
              //                 const SizedBox(height: 15),
              //                 DropdownButtonFormField<String>(
              //                   value: controller.selectedStatus.value,
              //                   items: controller.statuses.map((s) {
              //                     final dummyApp = AppointmentModel(
              //                       id: '',
              //                       clientName: '',
              //                       mobileNumber: '',
              //                       serviceName: '',
              //                       category: '',
              //                       visitingDateTime: DateTime.now(),
              //                       bookingDateTime: DateTime.now(),
              //                       status: s,
              //                       amount: 0,
              //                     );
              //                     return DropdownMenuItem(
              //                       value: s,
              //                       child: Text(dummyApp.statusKey.tr),
              //                     );
              //                   }).toList(),
              //                   onChanged: (v) => controller.updateStatus(v!),
              //                   decoration: InputDecoration(
              //                     labelText: "status".tr,
              //                     prefixIcon: const Icon(Icons.info_outline),
              //                   ),
              //                 ),
              //               ],
              //             );
              //           }),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.saveAppointment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "save_order".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      controller.saveAppointment(goToPreparation: true),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    "save_and_preparation".tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }



  void _showMultiSelectServiceDialog(BuildContext context) {
    controller.serviceSearchQuery.value = '';
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "services".tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search service...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) => controller.serviceSearchQuery.value = val,
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Obx(() {
                  final cats = controller.filteredCategories;
                  if (cats.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text("No categories found"),
                    );
                  }
                  return Column(
                    children: cats.map((categoryName) {
                      final isSelected = controller.selectedServices.contains(
                        categoryName,
                      );
                      return CheckboxListTile(
                        title: Text(
                          categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (bool? value) {
                          controller.toggleService(categoryName);
                        },
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                "done".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDateTimePicker(
    BuildContext context, {
    required String title,
    required Rx<DateTime> dateObs,
    required Rx<TimeOfDay> timeObs,
    required Function(DateTime) onDateChanged,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Obx(
      () {
        final dateStr = DateFormat('dd MMM yyyy').format(dateObs.value);
        final timeStr = timeObs.value.format(context);
        return ListTile(
          title: Text(title),
          subtitle: Text(
            "$dateStr, $timeStr",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          leading: const Icon(
            Icons.event_available_outlined,
            color: AppColors.primary,
          ),
          trailing: const Icon(Icons.edit_calendar, size: 20, color: AppColors.primary),
          contentPadding: EdgeInsets.zero,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: dateObs.value,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onDateChanged(date);
              if (context.mounted) {
                final time = await showTimePicker(
                  context: context,
                  initialTime: timeObs.value,
                );
                if (time != null) {
                  onTimeChanged(time);
                }
              }
            }
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
