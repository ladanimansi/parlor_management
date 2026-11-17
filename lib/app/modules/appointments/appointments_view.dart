import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/parlor_session.dart';
import '../../routes/app_routes.dart';
import 'appointments_controller.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MenuController>()) {
      Get.put(MenuController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Menu".tr,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
                width: 0.8,
              ),
            ),
            child: Text(
              ParlorSession.parlorTypeBadgeText,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. Services
          _buildMenuCard(
            title: "Services",
            subtitle: ParlorSession.serviceSubtitle,
            icon: Icons.spa_rounded,
            color: AppColors.primary,
            onTap: () => Get.toNamed(Routes.PRODUCT_CATEGORY),
          ),

          // 2. Products
          _buildMenuCard(
            title: "Products",
            subtitle: "Retail items, beauty kits & cosmetic stock",
            icon: Icons.inventory_2_rounded,
            color: const Color(0xFFC97A1E),
            onTap: () => Get.toNamed(Routes.PRODUCT_ITEM),
          ),

          // 3. Staff
          _buildMenuCard(
            title: "staff_master".tr,
            subtitle: "Stylists, beauticians & team members",
            icon: Icons.people_alt_rounded,
            color: AppColors.secondary,
            onTap: () => Get.toNamed(Routes.STAFF),
          ),

          // 4. Orders
          _buildMenuCard(
            title: "orders".tr,
            subtitle: "All client billing records & invoice logs",
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF1E7B68),
            onTap: () => Get.toNamed(Routes.ORDERS),
          ),

          // 5. Preparation
          _buildMenuCard(
            title: "preparation".tr,
            subtitle: "Pre-service checklist for booked orders",
            icon: Icons.auto_fix_high_rounded,
            color: const Color(0xFF6B46C1),
            onTap: () => Get.toNamed(Routes.ORDER_PREPARATION),
          ),

          // 6. Allocation
          _buildMenuCard(
            title: "allocation".tr,
            subtitle: "Assign staff specialists to pending orders",
            icon: Icons.assignment_ind_rounded,
            color: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(Routes.ORDER_ALLOCATION),
          ),

          // 7. Super Admin (Only shown if admin)
          if (controller.isAdmin)
            _buildMenuCard(
              title: "Admin Portal",
              subtitle: "Parlor management & system controls",
              icon: Icons.admin_panel_settings_rounded,
              color: AppColors.secondary,
              onTap: () => Get.toNamed(Routes.ADMIN),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Clean Tinted Icon Box
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Chevron Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
