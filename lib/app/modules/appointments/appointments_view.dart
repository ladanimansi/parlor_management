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
            leading: const Icon(Icons.spa, color: AppColors.primary),
            title: const Text(
              "Services",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.spa_outlined, color: Colors.grey),
                title: const Text("Services List"),
                subtitle: const Text("Hair Cut, Facial, Eyebrow, etc."),
                onTap: () {
                  Get.toNamed(Routes.PRODUCT_CATEGORY);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            leading: const Icon(Icons.inventory_2, color: AppColors.primary),
            title: const Text(
              "Products",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                title: const Text("Products List"),
                subtitle: const Text("Herbal Kit, Gold Kit, Serum, etc."),
                onTap: () {
                  Get.toNamed(Routes.PRODUCT_ITEM);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            leading: const Icon(Icons.people, color: AppColors.primary),
            title: Text(
              "staff_master".tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.grey),
                title: Text("staff".tr),
                onTap: () {
                  Get.toNamed(Routes.STAFF);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            leading: const Icon(Icons.shopping_cart, color: AppColors.primary),
            title: Text(
              "orders_master".tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.assignment_outlined, color: Colors.grey),
                title: Text("preparation".tr),
                onTap: () {
                  Get.toNamed(Routes.ORDER_PREPARATION);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.grey),
                title: Text("allocation".tr),
                onTap: () {
                  Get.toNamed(Routes.ORDER_ALLOCATION);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined, color: Colors.grey),
                title: Text("orders".tr),
                onTap: () {
                  Get.toNamed(Routes.ORDERS);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ExpansionTile(
            leading: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
            title: const Text(
              "Admin Master",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined, color: Colors.grey),
                title: const Text("Admin Portal"),
                subtitle: const Text("Hello Admin & Credentials"),
                onTap: () {
                  Get.toNamed(Routes.ADMIN);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
