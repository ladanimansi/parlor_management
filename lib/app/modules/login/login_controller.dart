import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  final GetStorage _storage = GetStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String adminEmail = 'mansiflutter79@gmail.com';
  static const String adminPassword = 'mansi2279';

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Check if Admin Login
      if (email == adminEmail) {
        bool isValidAdmin = false;

        // Verify with static credential or Firestore
        if (password == adminPassword) {
          isValidAdmin = true;
        } else {
          // Check Firestore collection 'admin'
          final query = await _firestore
              .collection('admin')
              .where('email', isEqualTo: email)
              .where('password', isEqualTo: password)
              .get();

          if (query.docs.isNotEmpty) {
            isValidAdmin = true;
          }
        }

        if (isValidAdmin) {
          // Save admin session in GetStorage
          await _storage.write('isLoggedIn', true);
          await _storage.write('userEmail', email);
          await _storage.write('userRole', 'admin');

          Get.snackbar(
            'Welcome',
            'Hello Admin, login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withValues(alpha: 0.15),
            colorText: AppColors.success,
          );

          // Navigate to Admin View
          Get.offAllNamed(Routes.ADMIN);
          return;
        } else {
          Get.snackbar(
            'Login Failed',
            'Invalid admin password. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            colorText: AppColors.error,
          );
          return;
        }
      }

      // If other (client) email entered
      Get.snackbar(
        'Client Login',
        'Client portal is coming soon. Please sign in with admin credentials.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        colorText: AppColors.primary,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
