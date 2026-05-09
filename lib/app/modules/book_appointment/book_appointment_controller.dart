import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/appointment_model.dart';
import '../../data/services/appointment_service.dart';

class BookAppointmentController extends GetxController {
  final AppointmentService _appointmentService = Get.find<AppointmentService>();

  final formKey = GlobalKey<FormState>();
  
  // Observables for state
  final isEdit = false.obs;
  final selectedAppointment = Rxn<AppointmentModel>();
  
  // Text Controllers
  late TextEditingController clientNameController;
  late TextEditingController mobileNumberController;
  late TextEditingController serviceNameController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late TextEditingController referenceByController;

  // Selected values
  final visitingDate = DateTime.now().obs;
  final visitingTime = TimeOfDay.now().obs;
  
  final bookingDate = DateTime.now().obs;
  final bookingTime = TimeOfDay.now().obs;

  final selectedCategories = <String>[].obs;
  final selectedStatus = 'Inquiry'.obs;

  final categories = ['General', 'Hair', 'Skin Care', 'Makeup', 'Nail Care', 'Spa'];
  final statuses = ['Inquiry', 'Confirm', 'InProgress', 'Completed', 'Cancelled'];

  @override
  void onInit() {
    super.onInit();
    
    // Check if we are in edit mode
    final args = Get.arguments;
    if (args != null && args is AppointmentModel) {
      isEdit.value = true;
      selectedAppointment.value = args;
      _prefillData(args);
    } else {
      _initNewData(args as DateTime?);
    }
  }

  void _initNewData(DateTime? initialDate) {
    clientNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    serviceNameController = TextEditingController();
    amountController = TextEditingController();
    notesController = TextEditingController();
    referenceByController = TextEditingController();
    
    if (initialDate != null) {
      bookingDate.value = initialDate;
    }
    selectedCategories.assignAll(['General']);
    // visitingDate remains now
  }

  void _prefillData(AppointmentModel appointment) {
    clientNameController = TextEditingController(text: appointment.clientName);
    mobileNumberController = TextEditingController(text: appointment.mobileNumber);
    serviceNameController = TextEditingController(text: appointment.serviceName);
    amountController = TextEditingController(text: appointment.amount.toString());
    notesController = TextEditingController(text: appointment.notes ?? "");
    referenceByController = TextEditingController(text: appointment.referenceBy ?? "");
    
    visitingDate.value = appointment.visitingDateTime;
    visitingTime.value = TimeOfDay.fromDateTime(appointment.visitingDateTime);
    
    bookingDate.value = appointment.bookingDateTime;
    bookingTime.value = TimeOfDay.fromDateTime(appointment.bookingDateTime);

    selectedCategories.assignAll(
      appointment.category.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
    );
    selectedStatus.value = appointment.status;
  }

  @override
  void onClose() {
    clientNameController.dispose();
    mobileNumberController.dispose();
    serviceNameController.dispose();
    amountController.dispose();
    notesController.dispose();
    referenceByController.dispose();
    super.onClose();
  }

  void updateVisitingDate(DateTime date) => visitingDate.value = date;
  void updateVisitingTime(TimeOfDay time) => visitingTime.value = time;
  
  void updateBookingDate(DateTime date) => bookingDate.value = date;
  void updateBookingTime(TimeOfDay time) => bookingTime.value = time;

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }
  void updateStatus(String status) => selectedStatus.value = status;

  void saveAppointment() {
    if (!formKey.currentState!.validate()) return;

    final finalVisitingDateTime = DateTime(
      visitingDate.value.year,
      visitingDate.value.month,
      visitingDate.value.day,
      visitingTime.value.hour,
      visitingTime.value.minute,
    );

    final finalBookingDateTime = DateTime(
      bookingDate.value.year,
      bookingDate.value.month,
      bookingDate.value.day,
      bookingTime.value.hour,
      bookingTime.value.minute,
    );

    final appointment = AppointmentModel(
      id: isEdit.value ? selectedAppointment.value!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: clientNameController.text,
      mobileNumber: mobileNumberController.text,
      serviceName: serviceNameController.text,
      category: selectedCategories.isEmpty ? 'General' : selectedCategories.join(', '),
      visitingDateTime: finalVisitingDateTime,
      bookingDateTime: finalBookingDateTime,
      status: selectedStatus.value,
      amount: double.tryParse(amountController.text) ?? 0.0,
      notes: notesController.text.isEmpty ? null : notesController.text,
      referenceBy: referenceByController.text.isEmpty ? null : referenceByController.text,
    );

    if (isEdit.value) {
      _appointmentService.updateAppointment(appointment);
      Get.back();
      Get.snackbar("success".tr, "appointment_updated".tr);
    } else {
      _appointmentService.addAppointment(appointment);
      Get.back();
      Get.snackbar("success".tr, "appointment_booked".tr);
    }
  }
}
