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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Product Item" : "Add Product Item"),
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
                hintText: "E.g., Gold Facial, Hair Spa...",
                labelText: "Item Name",
                prefixIcon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              decoration: InputDecoration(
                labelText: "Category",
                prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
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
              items: categoryController.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category["name"],
                  child: Text(category["name"]),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedCategory = val;
                  });
                }
              },
            ),
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
                isEdit ? "Update Item" : "Save Item", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
