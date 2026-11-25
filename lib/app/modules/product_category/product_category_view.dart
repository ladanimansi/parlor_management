import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import 'product_category_controller.dart';

class ProductCategoryView extends GetView<ProductCategoryController> {
  const ProductCategoryView({super.key});

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? category}) {
    Get.toNamed(Routes.ADD_PRODUCT_CATEGORY, arguments: category);
  }

  void _confirmDelete(BuildContext context, String id, String name) {
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
                "Are you sure you want to remove '$name'?",
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
                      controller.deleteCategory(id);
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

  @override
  Widget build(BuildContext context) {
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
            final count = controller.categories.length;
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
          // Search Box (Ultra Compact Flat)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
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
                        hintText: "Search services (Haircut, Facial, Spa)...",
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

          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEEEEEE)),

          // Seamless Flat List (No Cards, Zero Blank Gap)
          Expanded(
            child: Obx(() {
              final list = controller.filteredCategories;

              if (controller.categories.isEmpty) {
                return _buildEmptyState(
                  context,
                  title: "No Services Added Yet",
                  subtitle: "Add your salon services & beauty treatments.",
                  buttonText: "Add First Service",
                  onAction: () => _showAddEditDialog(context),
                );
              }

              if (list.isEmpty) {
                return _buildEmptyState(
                  context,
                  title: "No Matching Services",
                  subtitle: "No service found for '${controller.searchQuery.value}'.",
                  buttonText: "Clear Search",
                  onAction: () => controller.setSearchQuery(''),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 2, bottom: 80),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final category = list[index];
                  final isLast = index == list.length - 1;
                  return _buildCategoryRow(context, category, isLast);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "prod_cat_fab",
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: AppColors.primary,
        elevation: 2,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  // Flat Seamless Row with Divider (Zero Cards, Tight Spacing)
  Widget _buildCategoryRow(BuildContext context, Map<String, dynamic> category, bool isLast) {
    final String name = category["name"] ?? "";
    final String id = category["id"] ?? "";
    final bool isActive = category["status"] ?? true;

    return InkWell(
      onTap: () => _showAddEditDialog(context, category: category),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(
              children: [
                // Minimal Accent Bullet
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                // Name & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isActive ? "Active in Salon Menu" : "Inactive",
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: isActive ? AppColors.success : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Action
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 17),
                  color: AppColors.primary,
                  tooltip: "Edit",
                  onPressed: () => _showAddEditDialog(context, category: category),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                ),
                const SizedBox(width: 4),

                // Delete Action
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  color: AppColors.error,
                  tooltip: "Delete",
                  onPressed: () => _confirmDelete(context, id, name),
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
