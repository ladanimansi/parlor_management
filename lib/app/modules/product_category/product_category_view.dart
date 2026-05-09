import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'product_category_controller.dart';

class ProductCategoryView extends GetView<ProductCategoryController> {
  const ProductCategoryView({super.key});

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? category}) {
    Get.toNamed(Routes.ADD_PRODUCT_CATEGORY, arguments: category);
  }

  void _confirmDelete(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Category"),
        content: const Text("Are you sure you want to delete this category?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteCategory(id);
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Category'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: Text("No categories found."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  category["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showAddEditDialog(context, category: category),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, category["id"]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
