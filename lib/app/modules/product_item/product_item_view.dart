import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'product_item_controller.dart';

class ProductItemView extends GetView<ProductItemController> {
  const ProductItemView({super.key});

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? item}) {
    Get.toNamed(Routes.ADD_PRODUCT_ITEM, arguments: item);
  }

  void _confirmDelete(BuildContext context, String id) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Product Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              controller.deleteItem(id);
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
        title: const Text('Product Item'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return const Center(child: Text("No product items found."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  item["name"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Category: ${item['category']} | Price: ₹${item['price']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showAddEditDialog(context, item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, item["id"]),
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
