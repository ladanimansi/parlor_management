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
        title: Text(controller.isEdit.value ? "edit_appointment".tr : "book_appointment".tr),
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
                    Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedCategory.value,
                          items: controller.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => controller.updateCategory(v!),
                          decoration: InputDecoration(
                            labelText: "service_category".tr,
                            prefixIcon: const Icon(Icons.category_outlined),
                          ),
                        )),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: controller.serviceNameController,
                      decoration: InputDecoration(
                        labelText: "service_name".tr,
                        prefixIcon: const Icon(Icons.spa_outlined),
                      ),
                      validator: (v) => v!.isEmpty ? "required_field".tr : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: controller.amountController,
                      decoration: InputDecoration(
                        labelText: "amount".tr,
                        prefixIcon: const Icon(Icons.currency_rupee),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "required_field".tr : null,
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
                    Obx(() => DropdownButtonFormField<String>(
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
                            return DropdownMenuItem(value: s, child: Text(dummyApp.statusKey.tr));
                          }).toList(),
                          onChanged: (v) => controller.updateStatus(v!),
                          decoration: InputDecoration(
                            labelText: "status".tr,
                            prefixIcon: const Icon(Icons.info_outline),
                          ),
                        )),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    controller.isEdit.value ? "save_changes".tr : "book_now".tr,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildDateTimePicker(
    BuildContext context, {
    required String title,
    Rx<DateTime>? dateObs,
    Rx<TimeOfDay>? timeObs,
    Function(DateTime)? onDateChanged,
    Function(TimeOfDay)? onTimeChanged,
    bool isTime = false,
  }) {
    return Obx(() => ListTile(
          title: Text(title),
          subtitle: Text(
            isTime 
              ? timeObs!.value.format(context) 
              : DateFormat('dd MMM yyyy').format(dateObs!.value)
          ),
          leading: Icon(isTime ? Icons.access_time_outlined : Icons.calendar_today_outlined),
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
        ));
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
