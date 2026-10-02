import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/admin_model.dart';
import '../../routes/app_routes.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Static Admin Credentials requested
  static const String staticEmail = 'mansiflutter79@gmail.com';
  static const String staticPassword = 'mansi2279';

  final Rx<AdminModel?> currentAdmin = Rx<AdminModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString syncStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initStaticAdmin();
  }

  /// Initialize and ensure static admin exists in Firestore 'admin' table/collection
  Future<void> initStaticAdmin() async {
    try {
      isLoading.value = true;
      syncStatus.value = 'Connecting to Firebase...';

      // Use a designated document ID or query by email
      final adminDocRef = _firestore.collection('admin').doc('static_admin');
      final snapshot = await adminDocRef.get();

      if (!snapshot.exists) {
        // Document does not exist, create it with static details
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
        // Document exists, load existing data
        final data = snapshot.data();
        if (data != null) {
          currentAdmin.value = AdminModel.fromMap(data, docId: snapshot.id);
          syncStatus.value = 'Admin connected from Firebase';
        }
      }
    } catch (e) {
      syncStatus.value = 'Offline mode: Using local static admin';
      // In case of network delay or test mode before connectivity
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

  void logout() {
    final storage = GetStorage();
    storage.erase();
    Get.offAllNamed(Routes.LOGIN);
  }
}
