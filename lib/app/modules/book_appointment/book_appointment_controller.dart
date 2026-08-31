import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/services/appointment_service.dart';
import '../../data/services/customer_service.dart';
import '../product_category/product_category_controller.dart';
import '../product_item/product_item_controller.dart';
import '../services/services_controller.dart';
import '../../routes/app_routes.dart';

class BookAppointmentController extends GetxController {
  final AppointmentService _appointmentService = Get.find<AppointmentService>();
  final CustomerService _customerService = Get.find<CustomerService>();

  final formKey = GlobalKey<FormState>();
  
  // Observables for state
  final isEdit = false.obs;
  final selectedBookingType = 'Walk in orders'.obs;
  bool get isQuickBill => selectedBookingType.value == 'Walk in orders';
  final selectedAppointment = Rxn<AppointmentModel>();
  
  // Demographic variables
  final clientAge = RxnInt();
  final clientGender = ''.obs;
  final clientOtherInfo = ''.obs;
  final isNewCustomer = true.obs;

  // History variables
  final previousAppointments = <AppointmentModel>[].obs;
  final isHistoryExpanded = false.obs;
  
  // Service categories from Product Master
  final availableCategories = <String>[].obs;
  final selectedServices = <String>[].obs;  // stores selected category names
  final serviceSearchQuery = ''.obs;

  // Products configuration list
  final availableProducts = <Map<String, dynamic>>[].obs;
  final selectedProductIds = <String>{}.obs;

  List<String> get filteredCategories {
    if (serviceSearchQuery.value.isEmpty) return availableCategories;
    return availableCategories
        .where((c) => c.toLowerCase().contains(serviceSearchQuery.value.toLowerCase()))
        .toList();
  }

  void toggleService(String categoryName) {
    if (selectedServices.contains(categoryName)) {
      selectedServices.remove(categoryName);
    } else {
      selectedServices.add(categoryName);
    }
    _updateFromSelectedServices();
  }

  void _updateFromSelectedServices() {
    if (selectedServices.isEmpty) {
      serviceNameController.text = '';
      selectedCategories.clear();
      selectedProductIds.clear();
      amountController.text = '0';
    } else {
      serviceNameController.text = selectedServices.join(', ');
      selectedCategories.assignAll(selectedServices);
      
      // Auto-calculate billing amount based on service prices
      double total = 0;
      final servicesController = Get.find<ServicesController>();
      final Set<String> newRequiredProductIds = {};
      
      for (final serviceName in selectedServices) {
        final serviceModel = servicesController.allServices.firstWhereOrNull(
          (s) => s.name.toLowerCase() == serviceName.toLowerCase()
        );
        if (serviceModel != null) {
          total += serviceModel.price;
          newRequiredProductIds.addAll(serviceModel.requiredProductIds);
        }
      }
      amountController.text = total.toStringAsFixed(0);

      // Auto-select required products from Service Master
      selectedProductIds.assignAll(newRequiredProductIds);
    }
  }

  void toggleProductSelection(String productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  void _loadServicesFromProductMaster() {
    try {
      final categoryController = Get.find<ProductCategoryController>();
      final activeCategories = categoryController.categories
          .where((cat) => cat['status'] == true)
          .map<String>((cat) => cat['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      availableCategories.assignAll(activeCategories);
    } catch (e) {
      availableCategories.clear();
    }
  }

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
    
    // Load products list from master
    try {
      if (Get.isRegistered<ProductItemController>()) {
        final productItemController = Get.find<ProductItemController>();
        availableProducts.assignAll(productItemController.items);
      } else {
        final productItemController = Get.put(ProductItemController());
        availableProducts.assignAll(productItemController.items);
      }
    } catch (_) {}

    _loadServicesFromProductMaster();
    
    // Check if we are in edit mode
    final args = Get.arguments;
    if (args != null && args is AppointmentModel) {
      isEdit.value = true;
      selectedAppointment.value = args;
      _prefillData(args);
    } else {
      _initNewData(args as DateTime?);
    }

    mobileNumberController.addListener(_onMobileChanged);
    _onMobileChanged();
  }

  void _onMobileChanged() {
    final mobile = mobileNumberController.text.trim();
    checkPreviousBookings(mobile);
    _checkCustomerRegistration(mobile);
  }

  void _checkCustomerRegistration(String mobile) {
    if (mobile.length < 10) {
      isNewCustomer.value = true;
      // Do not clear name if user is typing it out
      return;
    }
    
    final customer = _customerService.getCustomerByMobile(mobile);
    if (customer != null) {
      isNewCustomer.value = false;
      clientNameController.text = customer.name;
      clientAge.value = customer.age;
      clientGender.value = customer.gender ?? '';
      clientOtherInfo.value = customer.otherInfo ?? '';
    } else {
      isNewCustomer.value = true;
      clientAge.value = null;
      clientGender.value = '';
      clientOtherInfo.value = '';
    }
  }

  void checkPreviousBookings(String mobile) {
    final cleanMobile = mobile.trim();
    if (cleanMobile.length < 10) {
      previousAppointments.clear();
      return;
    }
    
    // Find all appointments matching this mobile number, excluding the current one if editing
    final matches = _appointmentService.allAppointments.where((app) {
      final isSameMobile = app.mobileNumber.trim() == cleanMobile;
      final isDifferentId = !isEdit.value || app.id != selectedAppointment.value?.id;
      return isSameMobile && isDifferentId;
    }).toList();
    
    // Sort matches by date descending (latest first)
    matches.sort((a, b) => b.bookingDateTime.compareTo(a.bookingDateTime));
    
    previousAppointments.assignAll(matches);
    
    // Autofill client name if matches exist and clientName is empty/default
    if (matches.isNotEmpty && clientNameController.text.trim().isEmpty) {
      clientNameController.text = matches.first.clientName;
    }
  }

  void _initNewData(DateTime? initialDate) {
    clientNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    serviceNameController = TextEditingController();
    amountController = TextEditingController(text: '0');
    notesController = TextEditingController();
    referenceByController = TextEditingController();
    
    if (initialDate != null) {
      bookingDate.value = initialDate;
    }
    selectedCategories.assignAll(['General']);
    selectedBookingType.value = 'Walk in orders';
  }

  void _prefillData(AppointmentModel appointment) {
    clientNameController = TextEditingController(text: appointment.clientName);
    mobileNumberController = TextEditingController(text: appointment.mobileNumber);
    serviceNameController = TextEditingController(text: appointment.serviceName);
    amountController = TextEditingController(text: appointment.amount.toStringAsFixed(0));
    notesController = TextEditingController(text: appointment.notes ?? "");
    referenceByController = TextEditingController(text: appointment.referenceBy ?? "");
    
    visitingDate.value = appointment.visitingDateTime;
    visitingTime.value = TimeOfDay.fromDateTime(appointment.visitingDateTime);
    
    bookingDate.value = appointment.bookingDateTime;
    bookingTime.value = TimeOfDay.fromDateTime(appointment.bookingDateTime);

    selectedStatus.value = appointment.status;
    selectedBookingType.value = appointment.bookingType;

    // Prefill demographics
    clientAge.value = appointment.clientAge;
    clientGender.value = appointment.clientGender ?? '';
    clientOtherInfo.value = appointment.clientOtherInfo ?? '';

    // Restore selected services
    final names = appointment.serviceName.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    selectedServices.assignAll(names);
    selectedCategories.assignAll(names);

    // Restore selected products
    selectedProductIds.clear();
    if (appointment.selectedProducts != null) {
      final prodNames = appointment.selectedProducts!.split(',').map((e) => e.trim()).toList();
      for (final prodName in prodNames) {
        final prod = availableProducts.firstWhereOrNull((p) => p['name'] == prodName);
        if (prod != null) {
          selectedProductIds.add(prod['id'].toString());
        }
      }
    }
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

  void selectBookingType(String type) {
    if (!isEdit.value) {
      selectedBookingType.value = type;
    }
  }

  void saveAppointment({bool goToPreparation = false, bool goToAllocation = false}) {
    if (!formKey.currentState!.validate()) return;

    DateTime finalVisitingDateTime;
    DateTime finalBookingDateTime;
    String status;
    String? notes;
    String? referenceBy;

    if (isQuickBill) {
      finalVisitingDateTime = DateTime.now();
      finalBookingDateTime = DateTime.now();
      status = 'InProgress'; // Starts as InProgress for staff allocation and service execution
      notes = notesController.text.trim().isEmpty ? null : notesController.text.trim();
      referenceBy = null;
    } else {
      finalVisitingDateTime = DateTime(
        visitingDate.value.year,
        visitingDate.value.month,
        visitingDate.value.day,
        visitingTime.value.hour,
        visitingTime.value.minute,
      );

      finalBookingDateTime = DateTime(
        bookingDate.value.year,
        bookingDate.value.month,
        bookingDate.value.day,
        bookingTime.value.hour,
        bookingTime.value.minute,
      );
      status = selectedStatus.value;
      notes = notesController.text.isEmpty ? null : notesController.text;
      referenceBy = referenceByController.text.isEmpty ? null : referenceByController.text;
    }

    final clientName = clientNameController.text.trim().isEmpty
        ? 'walkin_client'.tr
        : clientNameController.text.trim();

    final serviceName = serviceNameController.text.trim().isEmpty
        ? (selectedServices.isNotEmpty ? selectedServices.join(', ') : 'General Service')
        : serviceNameController.text.trim();

    // Register / Update Customer Profile
    final cleanMobile = mobileNumberController.text.trim();
    if (cleanMobile.isNotEmpty) {
      final existingCust = _customerService.getCustomerByMobile(cleanMobile);
      final customer = CustomerModel(
        id: existingCust?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
        name: clientName,
        mobileNumber: cleanMobile,
        age: clientAge.value,
        gender: clientGender.value.isEmpty ? null : clientGender.value,
        otherInfo: clientOtherInfo.value.isEmpty ? null : clientOtherInfo.value,
      );
      _customerService.registerCustomer(customer);
    }

    // Build service-wise allocations
    final List<ServiceItemAllocation> allocations = [];
    final servicesController = Get.find<ServicesController>();
    for (final sName in selectedServices) {
      final serviceModel = servicesController.allServices.firstWhereOrNull(
        (s) => s.name.toLowerCase() == sName.toLowerCase()
      );
      if (serviceModel != null) {
        allocations.add(ServiceItemAllocation(
          serviceId: serviceModel.id,
          serviceName: serviceModel.name,
          price: serviceModel.price,
          status: 'Waiting', // Default status waiting for staff accept
        ));
      }
    }

    final prodNames = selectedProductIds.isNotEmpty
        ? availableProducts
            .where((p) => selectedProductIds.contains(p['id']))
            .map((p) => p['name'])
            .join(', ')
        : null;

    final appointment = AppointmentModel(
      id: isEdit.value ? selectedAppointment.value!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: clientName,
      mobileNumber: mobileNumberController.text,
      serviceName: serviceName,
      category: selectedCategories.isEmpty ? 'General' : selectedCategories.join(', '),
      visitingDateTime: finalVisitingDateTime,
      bookingDateTime: finalBookingDateTime,
      status: status,
      amount: double.tryParse(amountController.text) ?? 0.0,
      notes: notes,
      referenceBy: referenceBy,
      allocatedStaffId: isEdit.value ? selectedAppointment.value!.allocatedStaffId : null,
      allocatedStaffName: isEdit.value ? selectedAppointment.value!.allocatedStaffName : null,
      bookingType: selectedBookingType.value,
      clientAge: clientAge.value,
      clientGender: clientGender.value,
      clientOtherInfo: clientOtherInfo.value,
      selectedProducts: prodNames,
      paymentStatus: isEdit.value ? selectedAppointment.value!.paymentStatus : 'Pending',
      serviceAllocations: allocations,
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

    if (goToPreparation) {
      final initialCategory = selectedCategories.isNotEmpty ? selectedCategories.first : 'All';
      Get.toNamed(Routes.ORDER_PREPARATION, arguments: {
        'category': initialCategory,
        'appointmentId': appointment.id,
      });
    } else if (goToAllocation) {
      Get.toNamed(Routes.ORDER_ALLOCATION, arguments: {
        'appointmentId': appointment.id,
      });
    }
  }
}
