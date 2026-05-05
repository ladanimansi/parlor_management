import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/translations/translation_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
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
            const Text(
              "Admin User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text("admin@myparlor.com", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            _buildSection(
              title: "language".tr,
              children: [
                _buildLanguageTile("english".tr, "en", Icons.language),
                _buildLanguageTile("hindi".tr, "hi", Icons.translate),
                _buildLanguageTile("gujarati".tr, "gu", Icons.g_translate),
              ],
            ),
          ],
        ),
      ),
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
          backgroundColor: AppColors.primary.withOpacity(0.1),
          colorText: AppColors.primary,
        );
      },
    );
  }
}
