import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../product_category/product_category_controller.dart';
import 'product_item_controller.dart';

class AddProductItemView extends StatefulWidget {
  const AddProductItemView({super.key});

  @override
  State<AddProductItemView> createState() => _AddProductItemViewState();
}

class _AddProductItemViewState extends State<AddProductItemView> {
  final ProductItemController controller = Get.isRegistered<ProductItemController>()
      ? Get.find<ProductItemController>()
      : Get.put(ProductItemController());
  final ProductCategoryController categoryController = Get.find<ProductCategoryController>();
  late final bool isEdit;
  late final Map<String, dynamic>? item;
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    item = Get.arguments;
    isEdit = item != null;
    nameController = TextEditingController(text: isEdit ? item!["name"] : "");
    priceController = TextEditingController(text: isEdit ? item!["price"] : "");
    
    // Get category names
    final categoryNames = categoryController.categories.map((c) => c["name"] as String).toList();
    
    if (categoryNames.isEmpty) {
      selectedCategory = null;
    } else {
      selectedCategory = isEdit ? item!["category"] : categoryNames.first;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void _showQuickAddServiceDialog() {
    final textController = TextEditingController();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Add New Service",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: textController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Service Name",
                  hintText: "e.g. Hair Cut, Facial, Eyebrow",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                onSubmitted: (val) {
                  final name = val.trim();
                  if (name.isNotEmpty) {
                    categoryController.addCategory(name);
                    setState(() {
                      selectedCategory = name;
                    });
                    Get.back();
                    Get.snackbar(
                      "Success",
                      "Service '$name' added successfully",
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
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final name = textController.text.trim();
                      if (name.isNotEmpty) {
                        categoryController.addCategory(name);
                        setState(() {
                          selectedCategory = name;
                        });
                        Get.back();
                        Get.snackbar(
                          "Success",
                          "Service '$name' added successfully",
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    ),
                    child: const Text(
                      "Add Service",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Product" : "Add Product"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "E.g., Herbal Kit, Gold Facial Kit, Serum...",
                labelText: "Product Name",
                prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                hintText: "E.g., 1500",
                labelText: "Price",
                prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Obx(() {
              final servicesList = categoryController.categories
                  .map((c) => c["name"]?.toString() ?? "")
                  .where((name) => name.isNotEmpty)
                  .toList();

              if (selectedCategory != null && !servicesList.contains(selectedCategory)) {
                selectedCategory = servicesList.isNotEmpty ? servicesList.first : null;
              } else if (selectedCategory == null && servicesList.isNotEmpty) {
                selectedCategory = servicesList.first;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                      decoration: InputDecoration(
                        labelText: "Service",
                        hintText: "Select Service",
                        prefixIcon: const Icon(Icons.spa_outlined, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                      ),
                      items: servicesList.map((serviceName) {
                        return DropdownMenuItem<String>(
                          value: serviceName,
                          child: Text(serviceName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _showQuickAddServiceDialog,
                      child: const SizedBox(
                        height: 54,
                        width: 54,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty && selectedCategory != null) {
                  if (isEdit) {
                    controller.editItem(item!["id"], nameController.text, priceController.text, selectedCategory!);
                  } else {
                    controller.addItem(nameController.text, priceController.text, selectedCategory!);
                  }
                  Get.back();
                }
              },
              child: Text(
                isEdit ? "Update Product" : "Save Product", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
