import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/staff_model.dart';
import '../../data/services/staff_service.dart';
import '../product_category/product_category_controller.dart';

class AddStaffController extends GetxController {
  final StaffService _staffService = Get.find<StaffService>();
  final ProductCategoryController _categoryController = Get.find<ProductCategoryController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();

  final isEdit = false.obs;
  final selectedStaff = Rxn<StaffModel>();
  final selectedCategories = <String>[].obs;

  List<String> get productCategories {
    return _categoryController.categories
        .where((cat) => cat['status'] == true)
        .map<String>((cat) => cat['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    final allCats = productCategories;

    final arg = Get.arguments;
    if (arg != null && arg is StaffModel) {
      isEdit.value = true;
      selectedStaff.value = arg;
      nameController.text = arg.name;
      mobileController.text = arg.mobileNumber;
      selectedCategories.assignAll(arg.specialties);
    } else {
      // All categories selected by default
      selectedCategories.assignAll(allCats);
    }
  }

  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
  }

  bool isCategorySelected(String category) {
    return selectedCategories.contains(category);
  }

  void saveStaff() {
    if (!formKey.currentState!.validate()) return;

    if (selectedCategories.isEmpty) {
      Get.snackbar("warning".tr, "select_at_least_one_specialty".tr);
      return;
    }

    final staff = StaffModel(
      id: isEdit.value ? selectedStaff.value!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: nameController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      specialties: List<String>.from(selectedCategories),
    );

    if (isEdit.value) {
      _staffService.updateStaff(staff);
      Get.back();
      Get.snackbar("success".tr, "staff_updated_successfully".tr);
    } else {
      _staffService.addStaff(staff);
      Get.back();
      Get.snackbar("success".tr, "staff_added_successfully".tr);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
