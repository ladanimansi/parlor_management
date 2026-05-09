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
              _buildSectionTitle("client_details".tr),
              CustomCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.clientNameController,
                      decoration: InputDecoration(
                        labelText: "client_name".tr,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) => v!.isEmpty ? "required_field".tr : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: controller.mobileNumberController,
                      decoration: InputDecoration(
                        labelText: "mobile_number".tr,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? "required_field".tr : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("visiting_details".tr),
              CustomCard(
                child: Column(
                  children: [
                    _buildDateTimePicker(
                      context,
                      title: "visiting_date".tr,
                      dateObs: controller.visitingDate,
                      onDateChanged: controller.updateVisitingDate,
                    ),
                    const Divider(),
                    _buildDateTimePicker(
                      context,
                      title: "visiting_time".tr,
                      timeObs: controller.visitingTime,
                      onTimeChanged: controller.updateVisitingTime,
                      isTime: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("order_details".tr),
              CustomCard(
                child: Column(
                  children: [
                    _buildDateTimePicker(
                      context,
                      title: "order_date".tr,
                      dateObs: controller.bookingDate,
                      onDateChanged: controller.updateBookingDate,
                    ),
                    const Divider(),
                    _buildDateTimePicker(
                      context,
                      title: "order_time".tr,
                      timeObs: controller.bookingTime,
                      onTimeChanged: controller.updateBookingTime,
                      isTime: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("service_details".tr),
              CustomCard(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _showMultiSelectCategoryDialog(context),
                      child: Obx(() => InputDecorator(
                            decoration: InputDecoration(
                              labelText: "service_category".tr,
                              prefixIcon: const Icon(Icons.category_outlined),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            child: controller.selectedCategories.isEmpty
                                ? Text("select_category".tr, style: const TextStyle(color: Colors.grey))
                                : Wrap(
                                    spacing: 6.0,
                                    runSpacing: -8.0,
                                    children: controller.selectedCategories.map((c) {
                                      return Chip(
                                        label: Text(c, style: const TextStyle(fontSize: 12)),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: AppColors.primary.withOpacity(0.1),
                                        deleteIcon: const Icon(Icons.close, size: 14),
                                        onDeleted: () => controller.toggleCategory(c),
                                        side: BorderSide.none,
                                      );
                                    }).toList(),
                                  ),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle("additional_info".tr),
              CustomCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.notesController,
                      decoration: InputDecoration(
                        labelText: "notes".tr,
                        prefixIcon: const Icon(Icons.note_alt_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: controller.referenceByController,
                      decoration: InputDecoration(
                        labelText: "reference_by".tr,
                        prefixIcon: const Icon(Icons.group_outlined),
                        hintText: "e.g., Instagram, Friend, Google",
                      ),
                    ),
                    const SizedBox(height: 15),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
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
                            child: Text(dummyApp.statusKey.tr),
                          );
                        }).toList(),
                        onChanged: (v) => controller.updateStatus(v!),
                        decoration: InputDecoration(
                          labelText: "status".tr,
                          prefixIcon: const Icon(Icons.info_outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                    controller.isEdit.value ? "save_changes".tr : "book_now".tr,
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

  void _showMultiSelectCategoryDialog(BuildContext context) {
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
                "service_category".tr,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                  children: controller.categories.map((c) {
                    final isSelected = controller.selectedCategories.contains(c);
                    return CheckboxListTile(
                      title: Text(c),
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (bool? value) {
                        controller.toggleCategory(c);
                      },
                    );
                  }).toList(),
                )),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text("done".tr, style: const TextStyle(color: Colors.white)),
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
    Rx<DateTime>? dateObs,
    Rx<TimeOfDay>? timeObs,
    Function(DateTime)? onDateChanged,
    Function(TimeOfDay)? onTimeChanged,
    bool isTime = false,
  }) {
    return Obx(
      () => ListTile(
        title: Text(title),
        subtitle: Text(
          isTime
              ? timeObs!.value.format(context)
              : DateFormat('dd MMM yyyy').format(dateObs!.value),
        ),
        leading: Icon(
          isTime ? Icons.access_time_outlined : Icons.calendar_today_outlined,
        ),
        trailing: Icon(isTime ? Icons.edit : Icons.edit_calendar, size: 20),
        contentPadding: EdgeInsets.zero,
        onTap: () async {
          if (isTime) {
            final time = await showTimePicker(
              context: context,
              initialTime: timeObs!.value,
            );
            if (time != null) onTimeChanged!(time);
          } else {
            final date = await showDatePicker(
              context: context,
              initialDate: dateObs!.value,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) onDateChanged!(date);
          }
        },
      ),
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
