import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../data/models/service_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/custom_widgets/custom_card.dart';
import 'services_controller.dart';
import '../product_item/product_item_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("services".tr),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: Obx(() {
              if (controller.allServices.isEmpty) {
                return Center(child: Text("no_services_found".tr));
              }
              return AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: controller.services.length,
                  itemBuilder: (context, index) {
                    final service = controller.services[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 2,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildServiceCard(service),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "services_fab",
        onPressed: () => _showServiceForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(category), // Categories are dynamic, might not translate easily without a map
                selected: isSelected,
                onSelected: (selected) => controller.setCategory(category),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.cardLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    return CustomCard(
      padding: EdgeInsets.zero,
      onTap: () => _showServiceOptions(service),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(service.category),
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showServiceOptions(service),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Builder(
                    builder: (context) {
                      final prodController = Get.isRegistered<ProductItemController>()
                          ? Get.find<ProductItemController>()
                          : Get.put(ProductItemController());
                      final productNames = service.requiredProductIds
                          .map((id) => prodController.items.firstWhereOrNull((item) => item['id'] == id)?['name'] ?? '')
                          .where((name) => name.isNotEmpty)
                          .toList();
                      if (productNames.isEmpty) return const SizedBox.shrink();
                      return Text(
                        "Products: ${productNames.join(', ')}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${service.price}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        service.duration,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceOptions(ServiceModel service) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text("edit_service".tr),
              onTap: () {
                Get.back();
                _showServiceForm(service: service);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text("delete_service".tr),
              onTap: () {
                Get.back();
                _confirmDelete(service.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id) {
    Get.dialog(
      AlertDialog(
        title: Text("delete_service".tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text("cancel".tr)),
          TextButton(
            onPressed: () {
              controller.deleteService(id);
              Get.back();
            },
            child: Text("delete".tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showServiceForm({ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name ?? "");
    final priceController = TextEditingController(text: service?.price.toString() ?? "");
    final durationController = TextEditingController(text: service?.duration ?? "");
    String category = service?.category ?? controller.categories[1];
    final selectedProductIds = RxList<String>(service?.requiredProductIds ?? []);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                service == null ? "add_service".tr : "edit_service".tr,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "service_name".tr),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "amount".tr),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: durationController,
                decoration: InputDecoration(labelText: "time".tr),
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: category,
                items: controller.categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => category = val!,
                decoration: InputDecoration(labelText: "profile".tr), // Reusing profile key for category label or add new
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Required Products",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimaryLight),
                ),
              ),
              const SizedBox(height: 5),
              Builder(
                builder: (context) {
                  final prodController = Get.isRegistered<ProductItemController>()
                      ? Get.find<ProductItemController>()
                      : Get.put(ProductItemController());
                  final prods = prodController.items;
                  
                  return Obx(() {
                    if (prods.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("No products available", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      );
                    }
                    return Column(
                      children: prods.map((prod) {
                        final id = prod['id']?.toString() ?? '';
                        final name = prod['name']?.toString() ?? '';
                        final isChecked = selectedProductIds.contains(id);
                        return CheckboxListTile(
                          title: Text(name, style: const TextStyle(fontSize: 14)),
                          value: isChecked,
                          dense: true,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            if (val == true) {
                              selectedProductIds.add(id);
                            } else {
                              selectedProductIds.remove(id);
                            }
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    );
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  final newService = ServiceModel(
                    id: service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    duration: durationController.text,
                    category: category,
                    description: service?.description ?? "",
                    requiredProductIds: List<String>.from(selectedProductIds),
                  );
                  if (service == null) {
                    controller.addService(newService);
                  } else {
                    controller.updateService(newService);
                  }
                  Get.back();
                },
                child: Text(service == null ? "add_service".tr : "save_changes".tr),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bridal':
        return Icons.auto_awesome;
      case 'Hair':
        return Icons.content_cut;
      case 'Skin Care':
        return Icons.face;
      case 'Nail Care':
        return Icons.fingerprint;
      default:
        return Icons.spa;
    }
  }
}
