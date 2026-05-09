import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import '../../data/models/appointment_model.dart';
import '../../routes/app_routes.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("dashboard".tr),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Obx(() => controller.isExpanded.value ? const SizedBox.shrink() : _buildCalendar()),
          Obx(() => controller.isExpanded.value ? const SizedBox.shrink() : const SizedBox(height: 10)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.delta.dy < -2) {
                        controller.isExpanded.value = true;
                      } else if (details.delta.dy > 2) {
                        controller.isExpanded.value = false;
                      }
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: controller.toggleExpand,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                child: Obx(() => Icon(
                                      controller.isExpanded.value ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                      color: Colors.grey,
                                      size: 30,
                                    )),
                              ),
                            ),
                          ),
                          _buildHeaderRow(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(child: _buildAppointmentList()),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "dashboard_fab",
        onPressed: () => Get.toNamed(Routes.BOOK_APPOINTMENT, arguments: controller.selectedDay.value),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendar() {
    return Obx(() {
      return TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: controller.focusedDay.value,
        selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
        onDaySelected: controller.onDaySelected,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white),
        ),
      );
    });
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Text(
              DateFormat('MMMM dd, yyyy').format(controller.selectedDay.value),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
        Obx(() => Text(
              "bookings_count".trParams({'count': controller.dailyAppointments.length.toString()}),
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            )),
      ],
    );
  }

  Widget _buildAppointmentList() {
    return Obx(() {
      if (controller.dailyAppointments.isEmpty) {
        return Center(child: Text("no_appointments".tr));
      }
      return ListView.builder(
        itemCount: controller.dailyAppointments.length,
        itemBuilder: (context, index) {
          final appointment = controller.dailyAppointments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              onTap: () => Get.toNamed(Routes.BOOK_APPOINTMENT, arguments: appointment),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        DateFormat('hh:mm').format(appointment.bookingDateTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: appointment.status == 'Cancelled' ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        DateFormat('a').format(appointment.bookingDateTime),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const VerticalDivider(width: 30, thickness: 1),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: appointment.status == 'Cancelled' ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                appointment.clientName,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showStatusPicker(appointment),
                    child: _buildStatusBadge(appointment),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _confirmDelete(appointment.id),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
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
                  controller.updateAppointment(AppointmentModel(
                    id: appointment.id,
                    clientName: appointment.clientName,
                    mobileNumber: appointment.mobileNumber,
                    serviceName: appointment.serviceName,
                    category: appointment.category,
                    visitingDateTime: appointment.visitingDateTime,
                    bookingDateTime: appointment.bookingDateTime,
                    status: s,
                    amount: appointment.amount,
                    notes: appointment.notes,
                    referenceBy: appointment.referenceBy,
                  ));
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
