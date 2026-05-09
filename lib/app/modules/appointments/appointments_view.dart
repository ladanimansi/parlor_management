import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu".tr), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ExpansionTile(
            leading: const Icon(Icons.inventory, color: AppColors.primary),
            title: const Text(
              "Product Master",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.category, color: Colors.grey),
                title: const Text("Product Category"),
                onTap: () {
                  Get.toNamed(Routes.PRODUCT_CATEGORY);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.grey),
                title: const Text("Product Item"),
                onTap: () {
                  Get.toNamed(Routes.PRODUCT_ITEM);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
