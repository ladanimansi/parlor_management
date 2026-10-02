import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/admin_model.dart';
import '../../data/models/parlor_model.dart';
import '../../routes/app_routes.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static Admin Credentials requested
  static const String staticEmail = 'mansiflutter79@gmail.com';
  static const String staticPassword = 'mansi2279';

  final Rx<AdminModel?> currentAdmin = Rx<AdminModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString syncStatus = ''.obs;

  // Parlors (Client) Management
  final RxList<ParlorModel> parlors = <ParlorModel>[].obs;
  final RxBool isParlorsLoading = false.obs;
  final RxBool isAddingParlor = false.obs;
  final RxString searchQuery = ''.obs;

  List<ParlorModel> get filteredParlors {
    if (searchQuery.value.trim().isEmpty) {
      return parlors;
    }
    final q = searchQuery.value.trim().toLowerCase();
    return parlors.where((p) {
      return p.parlorName.toLowerCase().contains(q) ||
          p.ownerName.toLowerCase().contains(q) ||
          p.email.toLowerCase().contains(q) ||
          p.phone.contains(q) ||
          p.city.toLowerCase().contains(q);
    }).toList();
  }

  int get activeCount => parlors.where((p) => p.isActive).length;
  int get inactiveCount => parlors.where((p) => !p.isActive).length;

  // Form Controllers for Adding New Parlor
  final parlorNameController = TextEditingController();
  final ownerNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    initStaticAdmin();
    bindParlorsStream();
  }

  @override
  void onClose() {
    parlorNameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void clearForm() {
    parlorNameController.clear();
    ownerNameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
  }

  /// Initialize and ensure static admin exists in Firestore 'admin' table/collection
  Future<void> initStaticAdmin() async {
    try {
      isLoading.value = true;
      syncStatus.value = 'Connecting to Firebase...';

      final adminDocRef = _firestore.collection('admin').doc('static_admin');
      final snapshot = await adminDocRef.get();

      if (!snapshot.exists) {
        final initialAdmin = AdminModel(
          id: 'static_admin',
          email: staticEmail,
          password: staticPassword,
          role: 'admin',
          createdAt: DateTime.now(),
        );

        await adminDocRef.set(initialAdmin.toMap());
        currentAdmin.value = initialAdmin;
        syncStatus.value = 'Admin synced with Firebase';
        if (kDebugMode) {
          print('Admin table initialized with static admin in Firestore');
        }
      } else {
        final data = snapshot.data();
        if (data != null) {
          currentAdmin.value = AdminModel.fromMap(data, docId: snapshot.id);
          syncStatus.value = 'Admin connected from Firebase';
        }
      }
    } catch (e) {
      syncStatus.value = 'Offline mode: Using local static admin';
      currentAdmin.value = AdminModel(
        id: 'static_admin',
        email: staticEmail,
        password: staticPassword,
        role: 'admin',
      );
      if (kDebugMode) {
        print('Firestore admin error / offline fallback: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Realtime stream for registered Parlors / Clients
  void bindParlorsStream() {
    try {
      isParlorsLoading.value = true;
      _firestore
          .collection('parlors')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          parlors.assignAll(snapshot.docs.map((doc) {
            return ParlorModel.fromMap(doc.data(), docId: doc.id);
          }).toList());
          isParlorsLoading.value = false;
        },
        onError: (e) {
          if (kDebugMode) {
            print('Firestore parlors stream error: $e');
          }
          isParlorsLoading.value = false;
        },
      );
    } catch (e) {
      isParlorsLoading.value = false;
      if (kDebugMode) {
        print('Error setting up parlors stream: $e');
      }
    }
  }

  /// Add a new Parlor with credentials and basic details to Firestore
  Future<bool> addParlor() async {
    final parlorName = parlorNameController.text.trim();
    final ownerName = ownerNameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();

    // Validations
    if (parlorName.isEmpty) {
      _showSnackbar('Required Field', 'Please enter parlor / salon name', isError: true);
      return false;
    }
    if (ownerName.isEmpty) {
      _showSnackbar('Required Field', 'Please enter owner / contact person name', isError: true);
      return false;
    }
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      _showSnackbar('Required Field', 'Please enter a valid login email', isError: true);
      return false;
    }
    if (password.length < 6) {
      _showSnackbar('Weak Password', 'Password must be at least 6 characters long', isError: true);
      return false;
    }
    if (phone.isEmpty || phone.length < 10) {
      _showSnackbar('Required Field', 'Please enter a valid 10-digit phone number', isError: true);
      return false;
    }
    if (address.isEmpty) {
      _showSnackbar('Required Field', 'Please enter parlor address / location', isError: true);
      return false;
    }

    try {
      isAddingParlor.value = true;

      // Check if email already registered
      final existingEmailQuery = await _firestore
          .collection('parlors')
          .where('email', isEqualTo: email)
          .get();

      if (existingEmailQuery.docs.isNotEmpty || email == staticEmail) {
        _showSnackbar('Already Exists', 'This email is already registered for another parlor/admin', isError: true);
        return false;
      }

      // Add to Firestore collection 'parlors'
      final docRef = _firestore.collection('parlors').doc();
      final newParlor = ParlorModel(
        id: docRef.id,
        parlorName: parlorName,
        ownerName: ownerName,
        email: email,
        password: password,
        phone: phone,
        address: address,
        city: city,
        role: 'client',
        isActive: true,
        createdAt: DateTime.now(),
      );

      await docRef.set(newParlor.toMap());

      clearForm();
      _showSnackbar('Success', 'Parlor "$parlorName" registered successfully with login credentials!');
      return true;
    } catch (e) {
      _showSnackbar('Error', 'Failed to add parlor: $e', isError: true);
      return false;
    } finally {
      isAddingParlor.value = false;
    }
  }

  /// Toggle Active / Inactive status of a parlor
  Future<void> toggleParlorStatus(ParlorModel parlor) async {
    try {
      await _firestore
          .collection('parlors')
          .doc(parlor.id)
          .update({'isActive': !parlor.isActive});
      _showSnackbar('Updated', '${parlor.parlorName} status changed to ${!parlor.isActive ? "Active" : "Inactive"}');
    } catch (e) {
      _showSnackbar('Error', 'Could not update status: $e', isError: true);
    }
  }

  /// Delete a parlor
  Future<void> deleteParlor(String parlorId, String parlorName) async {
    try {
      await _firestore.collection('parlors').doc(parlorId).delete();
      _showSnackbar('Deleted', '$parlorName removed successfully');
    } catch (e) {
      _showSnackbar('Error', 'Could not delete parlor: $e', isError: true);
    }
  }

  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? AppColors.error.withValues(alpha: 0.12)
          : AppColors.success.withValues(alpha: 0.15),
      colorText: isError ? AppColors.error : AppColors.success,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void logout() {
    final storage = GetStorage();
    storage.erase();
    Get.offAllNamed(Routes.LOGIN);
  }
}
