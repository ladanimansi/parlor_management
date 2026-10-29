import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/translations/translation_service.dart';
import '../../core/utils/parlor_session.dart';
import '../../routes/app_routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final String parlorName = box.read('parlorName') ??
        (box.read('userRole') == 'admin' ? 'Admin User' : 'Parlor Salon');
    final String userEmail = box.read('userEmail') ?? 'admin@myparlor.com';

    return Scaffold(
      appBar: AppBar(
        title: Text("profile".tr),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              parlorName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(userEmail, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                box.read('userRole') == 'admin' ? '🛡️ Super Admin' : ParlorSession.parlorTypeBadgeText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildSection(
              title: "language".tr,
              children: [
                _buildLanguageTile("english".tr, "en", Icons.language),
                _buildLanguageTile("hindi".tr, "hi", Icons.translate),
                _buildLanguageTile("gujarati".tr, "gu", Icons.g_translate),
              ],
            ),
            const SizedBox(height: 25),
            _buildSection(
              title: "account".tr,
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout, color: Colors.red, size: 20),
                  ),
                  title: Text(
                    "logout".tr,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.red),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    Get.defaultDialog(
      title: "logout".tr,
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: "confirm_logout".tr,
      middleTextStyle: const TextStyle(fontSize: 14),
      textConfirm: "logout".tr,
      textCancel: "cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red.shade600,
      cancelTextColor: Colors.grey.shade700,
      radius: 12,
      onConfirm: () {
        final storage = GetStorage();
        storage.erase();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 0,
          color: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(String title, String code, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        TranslationService.changeLocale(code);
        Get.snackbar(
          "language".tr,
          "${"select_language".tr}: $title",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          colorText: AppColors.primary,
        );
      },
    );
  }
}
