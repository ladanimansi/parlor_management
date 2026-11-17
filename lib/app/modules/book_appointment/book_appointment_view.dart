import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/parlor_session.dart';
import '../../data/models/appointment_model.dart';
import 'book_appointment_controller.dart';

class BookAppointmentView extends GetView<BookAppointmentController> {
  const BookAppointmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F7),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Luxury Header Bar
                _buildHeaderBar(),

                // Main Form Content
                Expanded(
                  child: Form(
                    key: controller.formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Flow Type Horizontal Selector
                          _buildFlowTypeSelector(),

                          // Client Details Card
                          _buildClientDetailsCard(),

                          // Visiting Details Card (Visible in Pre-Booking mode)
                          _buildVisitingDetailsCard(context),

                          // Order Schedule (Date & Time) Card
                          _buildOrderScheduleCard(context),

                          // Services & Treatments Card
                          _buildServicesCard(context),

                          // Status Selector Card
                          _buildStatusCard(),

                          // Action Buttons
                          _buildActionButtons(),

                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Saving Progress Overlay
            _buildSavingOverlay(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP LUXURY HEADER BAR (Replaces traditional bulky AppBar)
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 15,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Text(
                    controller.isEdit.value
                        ? "edit_appointment".tr
                        : "book_appointment".tr,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Text(
                  "Salon Appointment & Billing",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    controller.isQuickBill ? "Quick Bill" : "Booking",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FLOW TYPE SELECTOR
  // ---------------------------------------------------------------------------
  Widget _buildFlowTypeSelector() {
    return Obx(() {
      final selectedType = controller.selectedBookingType.value;
      final allTypes = [
        {
          'name': 'Walk in orders',
          'key': 'walk_in_orders',
          'icon': Icons.directions_walk_rounded,
        },
        {
          'name': 'Advance appoinment',
          'key': 'advance_appointment',
          'icon': Icons.calendar_month_rounded,
        },
        {
          'name': 'Bridal Orders',
          'key': ParlorSession.bridalFlowKey,
          'icon': ParlorSession.isMale
              ? Icons.face_retouching_natural_rounded
              : Icons.auto_awesome_rounded,
        },
        {
          'name': 'Package',
          'key': 'package',
          'icon': Icons.card_membership_rounded,
        },
        {
          'name': 'Home service',
          'key': 'home_service',
          'icon': Icons.home_rounded,
        },
      ];

      final types = allTypes
          .where(
            (type) => controller.isFlowTypeAllowed(type['name'] as String),
          )
          .toList();

      if (types.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "flow_type".tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: types.length,
                itemBuilder: (context, index) {
                  final type = types[index];
                  final typeName = type['name'] as String;
                  final isSelected = selectedType == typeName;
                  final icon = type['icon'] as IconData;
                  final labelKey = type['key'] as String;

                  return Padding(
                    padding: const EdgeInsets.only(right: 7.0),
                    child: InkWell(
                      onTap: () => controller.selectBookingType(typeName),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFFC77E88), AppColors.primary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: 1.1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 7,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              labelKey.tr,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.secondary,
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
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // CLIENT DETAILS CARD
  // ---------------------------------------------------------------------------
  Widget _buildClientDetailsCard() {
    return _buildSalonCard(
      title: "client_details".tr,
      icon: Icons.person_rounded,
      trailing: Obx(() {
        final isNew = controller.isNewCustomer.value;
        final mobile = controller.mobileNumberController.text;
        if (mobile.length < 10) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: isNew ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isNew ? Colors.orange.shade400 : Colors.green.shade400,
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isNew ? Icons.person_add_alt_1_rounded : Icons.verified_rounded,
                size: 12,
                color: isNew ? Colors.orange.shade800 : Colors.green.shade800,
              ),
              const SizedBox(width: 4),
              Text(
                isNew ? "New Client" : "VIP / Existing",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isNew ? Colors.orange.shade900 : Colors.green.shade900,
                ),
              ),
            ],
          ),
        );
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mobile Number Input
          Obx(
            () => TextFormField(
              controller: controller.mobileNumberController,
              keyboardType: TextInputType.phone,
              decoration: _salonInputDecoration(
                labelText: controller.isQuickBill
                    ? "${'mobile_number'.tr} (Optional)"
                    : 'mobile_number'.tr,
                prefixIcon: Icons.phone_outlined,
              ),
              validator: (v) {
                if (controller.isQuickBill) return null;
                return (v == null || v.isEmpty) ? "required_field".tr : null;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Client Name Input
          Obx(
            () => TextFormField(
              controller: controller.clientNameController,
              textCapitalization: TextCapitalization.words,
              decoration: _salonInputDecoration(
                labelText: controller.isQuickBill
                    ? "${'client_name'.tr} (Optional)"
                    : 'client_name'.tr,
                prefixIcon: Icons.badge_outlined,
              ),
              validator: (v) {
                if (controller.isQuickBill) return null;
                return (v == null || v.isEmpty) ? "required_field".tr : null;
              },
            ),
          ),
          const SizedBox(height: 8),

          // Customer Gender (Only for Unisex Salon)
          if (ParlorSession.isUnisex) ...[
            Obx(() {
              final currentGender = controller.clientGender.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Text(
                      "customer_gender".tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    _buildGenderPill(
                      label: "Female",
                      icon: Icons.female_rounded,
                      isSelected: currentGender == 'Female',
                      selectedColor: Colors.pink.shade400,
                      onTap: () => controller.clientGender.value = 'Female',
                    ),
                    const SizedBox(width: 8),
                    _buildGenderPill(
                      label: "Male",
                      icon: Icons.male_rounded,
                      isSelected: currentGender == 'Male',
                      selectedColor: Colors.blue.shade500,
                      onTap: () => controller.clientGender.value = 'Male',
                    ),
                  ],
                ),
              );
            }),
          ],

          // Age Input
          Obx(() {
            return TextFormField(
              decoration: _salonInputDecoration(
                labelText: "Age (Optional)",
                prefixIcon: Icons.cake_outlined,
              ),
              keyboardType: TextInputType.number,
              initialValue: controller.clientAge.value?.toString() ?? '',
              onChanged: (val) {
                controller.clientAge.value = int.tryParse(val);
              },
              key: ValueKey('age_${controller.clientAge.value}'),
            );
          }),

          // Collapsible History
          _buildClientHistorySection(),
        ],
      ),
    );
  }

  Widget _buildGenderPill({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedColor : Colors.grey.shade300,
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? selectedColor : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? selectedColor : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientHistorySection() {
    return Obx(() {
      if (controller.previousAppointments.isEmpty) {
        return const SizedBox.shrink();
      }

      final count = controller.previousAppointments.length;
      final isExpanded = controller.isHistoryExpanded.value;

      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFBF8F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => controller.isHistoryExpanded.toggle(),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "History ($count previous orders)",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              const Divider(height: 1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: count,
                itemBuilder: (context, index) {
                  final app = controller.previousAppointments[index];
                  final dateStr = DateFormat(
                    'dd MMM yyyy, hh:mm a',
                  ).format(app.bookingDateTime);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: index == count - 1
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade200,
                                width: 0.8,
                              ),
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app.serviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: AppColors.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "₹${app.amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Builder(
                          builder: (context) {
                            String staffInfo = 'Staff: ';
                            if (app.serviceAllocations.isNotEmpty) {
                              staffInfo += app.serviceAllocations
                                  .map(
                                    (sa) =>
                                        "${sa.serviceName} (${sa.staffName ?? 'Pending'})",
                                  )
                                  .join(', ');
                            } else {
                              staffInfo += app.allocatedStaffName ??
                                  'Pending Staff Allocation';
                            }
                            return Text(
                              staffInfo,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
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
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: app.paymentStatus.toLowerCase() ==
                                            'paid'
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    app.paymentStatus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: app.paymentStatus.toLowerCase() ==
                                              'paid'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: app.statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
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
      );
    });
  }

  // ---------------------------------------------------------------------------
  // VISITING DETAILS CARD (Pre-Booking Mode)
  // ---------------------------------------------------------------------------
  Widget _buildVisitingDetailsCard(BuildContext context) {
    return Obx(() {
      if (controller.isQuickBill) return const SizedBox.shrink();
      return _buildSalonCard(
        title: "visiting_details".tr,
        icon: Icons.event_note_rounded,
        child: _buildInteractiveSchedulePills(
          context,
          dateObs: controller.visitingDate,
          timeObs: controller.visitingTime,
          onDateChanged: controller.updateVisitingDate,
          onTimeChanged: controller.updateVisitingTime,
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // ORDER SCHEDULE CARD (Date & Time)
  // ---------------------------------------------------------------------------
  Widget _buildOrderScheduleCard(BuildContext context) {
    return _buildSalonCard(
      title: "order_details".tr,
      icon: Icons.access_time_filled_rounded,
      child: _buildInteractiveSchedulePills(
        context,
        dateObs: controller.bookingDate,
        timeObs: controller.bookingTime,
        onDateChanged: controller.updateBookingDate,
        onTimeChanged: controller.updateBookingTime,
      ),
    );
  }

  Widget _buildInteractiveSchedulePills(
    BuildContext context, {
    required Rx<DateTime> dateObs,
    required Rx<TimeOfDay> timeObs,
    required Function(DateTime) onDateChanged,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Obx(() {
      final dateStr = DateFormat('dd MMM yyyy').format(dateObs.value);
      final dayName = DateFormat('EEEE').format(dateObs.value);
      final timeStr = timeObs.value.format(context);

      return Row(
        children: [
          // Date Selector Pill
          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: dateObs.value,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          onSurface: AppColors.secondary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  onDateChanged(date);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Time Selector Pill
          Expanded(
            child: InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: timeObs.value,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          onSurface: AppColors.secondary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (time != null) {
                  onTimeChanged(time);
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TIME",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // ---------------------------------------------------------------------------
  // SERVICES & TREATMENTS CARD
  // ---------------------------------------------------------------------------
  Widget _buildServicesCard(BuildContext context) {
    return _buildSalonCard(
      title: "service_details".tr,
      icon: Icons.spa_rounded,
      trailing: Obx(() {
        final count = controller.selectedServices.length;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$count Selected",
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        );
      }),
      child: FormField<List<String>>(
        validator: (v) => controller.selectedServices.isEmpty
            ? "required_field".tr
            : null,
        builder: (state) {
          return Obx(() {
            final errorText = state.errorText;
            final hasError =
                errorText != null && controller.selectedServices.isEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector Bar with + Button
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showMultiSelectServiceDialog(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF8F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasError
                                  ? AppColors.error
                                  : Colors.grey.shade200,
                              width: 1.1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 17,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  controller.selectedServices.isEmpty
                                      ? "select_service".tr
                                      : "${controller.selectedServices.length} categories chosen",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: controller.selectedServices.isEmpty
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: controller.selectedServices.isEmpty
                                        ? Colors.grey.shade500
                                        : AppColors.secondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey.shade600,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick Add Category Button
                    InkWell(
                      onTap: () => _showQuickAddCategoryDialog(context),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC77E88), AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ),
                  ],
                ),

                // Validation Error Message
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      errorText,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.error,
                      ),
                    ),
                  ),

                // Selected Services Chips
                if (controller.selectedServices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: controller.selectedServices.map((categoryName) {
                      return Container(
                        padding: const EdgeInsets.only(
                          left: 9,
                          right: 4,
                          top: 3.5,
                          bottom: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              categoryName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => controller.toggleService(categoryName),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            );
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATUS SELECTOR CARD
  // ---------------------------------------------------------------------------
  Widget _buildStatusCard() {
    return _buildSalonCard(
      title: "status".tr,
      icon: Icons.flag_rounded,
      child: Obx(
        () => DropdownButtonFormField<String>(
          initialValue: controller.statuses.contains(controller.selectedStatus.value)
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
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dummyApp.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dummyApp.statusKey.tr,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) controller.updateStatus(v);
          },
          decoration: _salonInputDecoration(
            labelText: "status".tr,
            prefixIcon: Icons.info_outline_rounded,
          ),
          icon: const Icon(Icons.arrow_drop_down_rounded),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTION BUTTONS
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Column(
        children: [
          // Primary Button: Save Order
          Obx(() {
            final isSaving = controller.isSaving.value;
            return InkWell(
              onTap: isSaving ? null : () => controller.saveAppointment(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: isSaving
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFC77E88), AppColors.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: isSaving ? AppColors.primary.withValues(alpha: 0.5) : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSaving
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSaving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    else ...[
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "save_order".tr,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // Secondary Button: Save & Preparation
          Obx(() {
            final isSaving = controller.isSaving.value;
            return InkWell(
              onTap: isSaving
                  ? null
                  : () => controller.saveAppointment(goToPreparation: true),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: isSaving
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF3B4F63), AppColors.secondary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: isSaving
                      ? AppColors.secondary.withValues(alpha: 0.5)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSaving
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSaving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.2,
                        ),
                      )
                    else ...[
                      const Icon(
                        Icons.room_service_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "save_and_preparation".tr,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SAVING FULL-SCREEN OVERLAY
  // ---------------------------------------------------------------------------
  Widget _buildSavingOverlay() {
    return Obx(() {
      if (!controller.isSaving.value) return const SizedBox.shrink();
      return Container(
        color: Colors.black.withValues(alpha: 0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Saving Appointment...",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // HELPER STYLING METHODS
  // ---------------------------------------------------------------------------
  Widget _buildSalonCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5.5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary.withValues(alpha: 0.75),
                  letterSpacing: 0.8,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  InputDecoration _salonInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFFBF8F9),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 16),
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MULTI SELECT SERVICE BOTTOM SHEET
  // ---------------------------------------------------------------------------
  void _showMultiSelectServiceDialog(BuildContext context) {
    controller.serviceSearchQuery.value = '';
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.spa_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "services".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: "Add Category",
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        onPressed: () => _showQuickAddCategoryDialog(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                decoration: _salonInputDecoration(
                  labelText: "Search service...",
                  prefixIcon: Icons.search_rounded,
                ),
                onChanged: (val) => controller.serviceSearchQuery.value = val,
              ),
            ),
            const Divider(height: 1),

            // List of Categories
            Flexible(
              child: SingleChildScrollView(
                child: Obx(() {
                  final cats = controller.filteredCategories;
                  if (cats.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 38,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No categories found",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showQuickAddCategoryDialog(context),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text("Add Category"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.secondary,
                          ),
                        ),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        onChanged: (bool? value) {
                          controller.toggleService(categoryName);
                        },
                      );
                    }).toList(),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),

            // Done Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFC77E88), AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "done".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ---------------------------------------------------------------------------
  // QUICK ADD CATEGORY DIALOG
  // ---------------------------------------------------------------------------
  void _showQuickAddCategoryDialog(BuildContext context) {
    final textController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Add Service Category",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: _salonInputDecoration(
                  labelText: "Category Name",
                  hintText: "e.g. Hair Cut, Facial, Spa",
                  prefixIcon: Icons.edit_note_rounded,
                ),
                onSubmitted: (val) {
                  final name = val.trim();
                  if (name.isNotEmpty) {
                    controller.addQuickCategory(name);
                    Get.back();
                    Get.snackbar(
                      "Success",
                      "Category '$name' added successfully",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.shade600,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(12),
                      borderRadius: 10,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "cancel".tr.isNotEmpty ? "cancel".tr : "Cancel",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final name = textController.text.trim();
                      if (name.isNotEmpty) {
                        controller.addQuickCategory(name);
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Category '$name' added successfully",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade600,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(12),
                          borderRadius: 10,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Add Category",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
