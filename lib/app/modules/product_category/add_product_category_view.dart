import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'product_category_controller.dart';

class AddProductCategoryView extends GetView<ProductCategoryController> {
  const AddProductCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? category = Get.arguments;
    final bool isEdit = category != null;
    final textController = TextEditingController(text: isEdit ? category["name"] : "");

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Category" : "Add Category"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: "E.g., Hair Care, Facial...",
                labelText: "Category Name",
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
              autofocus: true,
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
                if (textController.text.isNotEmpty) {
                  if (isEdit) {
                    controller.editCategory(category["id"], textController.text);
                  } else {
                    controller.addCategory(textController.text);
                  }
                  Get.back();
                }
              },
              child: Text(
                isEdit ? "Update Category" : "Save Category", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
}
