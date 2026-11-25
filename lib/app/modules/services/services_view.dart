import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/service_model.dart';
import '../../core/theme/app_colors.dart';
import 'services_controller.dart';

class ServicesView extends GetView<ServicesController> {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ServicesController>()) {
      Get.put(ServicesController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimaryLight,
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Services & Treatments",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
        actions: [
          Obx(() {
            final count = controller.services.length;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "$count ${count == 1 ? 'Service' : 'Services'}",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // Flat Clean Search Bar (Ultra Compact)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200, width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) => controller.setSearchQuery(val),
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search services (e.g. Haircut, Facial, Spa)...",
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return InkWell(
                        onTap: () => controller.setSearchQuery(''),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.clear_rounded, size: 15, color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // Flat Category Selector (Pills)
          _buildCategoryFilter(),

          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),

          // Main Seamless Flat List (No Cards, Zero Blank Gap)
          Expanded(
            child: Obx(() {
              if (controller.allServices.isEmpty) {
                return _buildEmptyState(
                  context,
                  title: "No Services Available",
                  subtitle: "Add your first salon service to create your treatment rate list.",
                  buttonText: "Add First Service",
                  onAction: () => _showServiceForm(),
                );
              }

              if (controller.services.isEmpty) {
                return _buildEmptyState(
                  context,
                  title: "No Matching Services",
                  subtitle: "No service found matching your filter.",
                  buttonText: "Show All Services",
                  onAction: () {
                    controller.setCategory('All');
                    controller.setSearchQuery('');
                  },
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 2, bottom: 80),
                itemCount: controller.services.length,
                itemBuilder: (context, index) {
                  final service = controller.services[index];
                  final isLast = index == controller.services.length - 1;
                  return _buildServiceRow(service, isLast);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "services_fab",
        onPressed: () => _showServiceForm(),
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 34,
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => controller.setCategory(category),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade200,
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // Seamless Luxury Flat Row (Zero Cards, Tight Spacing, Clean Lines)
  Widget _buildServiceRow(ServiceModel service, bool isLast) {
    return InkWell(
      onTap: () => _showServiceOptions(service),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minimal Primary Accent Bullet
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                // Name, Category & Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text(
                            service.category,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          if (service.duration.isNotEmpty) ...[
                            Text(
                              "  •  ${service.duration}",
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Price
                Text(
                  "₹${service.price.toStringAsFixed(0)}",
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(width: 4),

                // Options Menu Icon
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 17),
                  color: Colors.grey.shade400,
                  onPressed: () => _showServiceOptions(service),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              thickness: 0.6,
              indent: 32,
              endIndent: 16,
              color: Colors.grey.shade100,
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
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              service.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: Text(
                "Edit Service",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              onTap: () {
                Get.back();
                _showServiceForm(service: service);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text(
                "Delete Service",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                Get.back();
                _confirmDelete(service.id, service.name);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(String id, String name) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delete Service",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to delete '$name'?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      controller.deleteService(id);
                      Get.back();
                    },
                    child: Text(
                      "Delete",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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

  void _showServiceForm({ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name ?? "");
    final priceController = TextEditingController(text: service?.price.toString() ?? "");
    final durationController = TextEditingController(text: service?.duration ?? "");
    String category = service?.category ?? controller.categories.firstWhere((c) => c != 'All', orElse: () => 'Hair');
    final selectedProductIds = RxList<String>(service?.requiredProductIds ?? []);

    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                service == null ? "Add Service" : "Edit Service",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: nameController,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: "Service Name",
                  hintText: "e.g. Haircut, Gold Facial, Spa",
                  prefixIcon: const Icon(Icons.spa_outlined, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: "Price (₹)",
                  hintText: "e.g. 500",
                  prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: durationController,
                style: GoogleFonts.poppins(fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: "Duration",
                  hintText: "e.g. 30 min, 1 hour",
                  prefixIcon: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: category,
                items: controller.categories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: GoogleFonts.poppins(fontSize: 13.5)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) category = val;
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final newService = ServiceModel(
                    id: service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text.trim(),
                    price: double.tryParse(priceController.text) ?? 0.0,
                    duration: durationController.text.trim(),
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
                child: Text(
                  service == null ? "Save Service" : "Update Service",
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_outlined, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                side: const BorderSide(color: AppColors.primary, width: 0.8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
