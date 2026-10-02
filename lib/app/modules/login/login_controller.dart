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

      // Check registered Parlors / Clients in Firestore
      final parlorQuery = await _firestore
          .collection('parlors')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (parlorQuery.docs.isNotEmpty) {
        final parlorData = parlorQuery.docs.first.data();
        final bool isActive = parlorData['isActive'] ?? true;
        final String parlorName = parlorData['parlorName'] ?? 'Parlor';

        if (!isActive) {
          Get.snackbar(
            'Account Inactive',
            'Your parlor account has been deactivated. Please contact administrator.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withValues(alpha: 0.12),
            colorText: AppColors.error,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        // Save Parlor Session
        await _storage.write('isLoggedIn', true);
        await _storage.write('userEmail', email);
        await _storage.write('userRole', 'parlor');
        await _storage.write('parlorId', parlorQuery.docs.first.id);
        await _storage.write('parlorName', parlorName);

        Get.snackbar(
          'Welcome',
          'Welcome to $parlorName!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          colorText: AppColors.success,
        );

        // Navigate to Parlor Salon Dashboard
        Get.offAllNamed(Routes.HOME);
        return;
      }

      // If credentials do not match any admin or parlor
      Get.snackbar(
        'Login Failed',
        'Invalid email or password. Please check your credentials.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
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
