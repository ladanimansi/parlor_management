import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/parlor_session.dart';

class ProductCategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh list with default services for seamless display
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _categorySubscription;

  List<Map<String, dynamic>> get filteredCategories {
    if (searchQuery.value.trim().isEmpty) {
      return categories;
    }
    final q = searchQuery.value.toLowerCase().trim();
    return categories.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
  }

  String get currentParlorId {
    final id = _storage.read('parlorId');
    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
    return 'default_parlor';
  }

  CollectionReference<Map<String, dynamic>> get _categoryCollection {
    return _firestore
        .collection('parlors')
        .doc(currentParlorId)
        .collection('services');
  }

  List<Map<String, dynamic>> _getDefaultServicesForSession() {
    if (ParlorSession.isMale) {
      return [
        {"id": "s_1", "name": "Hair Cut & Styling", "status": true},
        {"id": "s_2", "name": "Beard Trim & Shape", "status": true},
        {"id": "s_3", "name": "Royal Shave", "status": true},
        {"id": "s_4", "name": "Head Oil Massage", "status": true},
        {"id": "s_5", "name": "D-Tan Face Treatment", "status": true},
        {"id": "s_6", "name": "Gold Facial Care", "status": true},
        {"id": "s_7", "name": "Hair Color / Dye", "status": true},
        {"id": "s_8", "name": "Groom Special Package", "status": true},
      ];
    } else if (ParlorSession.isUnisex) {
      return [
        {"id": "s_1", "name": "Hair Cut & Styling", "status": true},
        {"id": "s_2", "name": "Hair Spa & Conditioning", "status": true},
        {"id": "s_3", "name": "Gold Radiance Facial", "status": true},
        {"id": "s_4", "name": "Fruit Cleanup & D-Tan", "status": true},
        {"id": "s_5", "name": "Waxing & Threading", "status": true},
        {"id": "s_6", "name": "Hair Color / Highlights", "status": true},
        {"id": "s_7", "name": "Manicure & Pedicure", "status": true},
      ];
    } else {
      return [
        {"id": "s_1", "name": "Hair Cut & Blow Dry", "status": true},
        {"id": "s_2", "name": "Eyebrow & Upper Lip Threading", "status": true},
        {"id": "s_3", "name": "Full Arms & Legs Waxing", "status": true},
        {"id": "s_4", "name": "Fruit Cleanup & Glow", "status": true},
        {"id": "s_5", "name": "Gold Radiance Facial", "status": true},
        {"id": "s_6", "name": "D-Tan & Bleach Treatment", "status": true},
        {"id": "s_7", "name": "Hair Spa & Scalp Care", "status": true},
        {"id": "s_8", "name": "Bridal Special Glow Pack", "status": true},
      ];
    }
  }

  @override
  void onInit() {
    super.onInit();
    if (categories.isEmpty) {
      categories.assignAll(_getDefaultServicesForSession());
    }
    bindCategoriesStream();
  }

  @override
  void onClose() {
    _categorySubscription?.cancel();
    super.onClose();
  }

  void bindCategoriesStream() {
    try {
      _categorySubscription?.cancel();
      _categorySubscription = _categoryCollection.snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            categories.assignAll(snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
          }
        },
        onError: (err) {
          if (kDebugMode) {
            print('Firestore categories stream error: $err');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up categories stream: $e');
      }
    }
  }

  void addCategory(String name) async {
    if (name.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newCategory = {
      "id": id,
      "name": name.trim(),
      "status": true,
    };
    categories.add(newCategory);

    try {
      await _categoryCollection.doc(id).set(newCategory);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding category to Firestore: $e');
      }
    }
  }

  void editCategory(String id, String newName) async {
    if (newName.trim().isEmpty) return;
    final index = categories.indexWhere((cat) => cat["id"] == id);
    if (index != -1) {
      categories[index]["name"] = newName.trim();
      categories.refresh();
    }

    try {
      await _categoryCollection.doc(id).update({"name": newName.trim()});
    } catch (e) {
      if (kDebugMode) {
        print('Error editing category in Firestore: $e');
      }
    }
  }

  void deleteCategory(String id) async {
    categories.removeWhere((cat) => cat["id"] == id);
    try {
      await _categoryCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting category from Firestore: $e');
      }
    }
  }

  void toggleStatus(String id) async {
    final index = categories.indexWhere((cat) => cat["id"] == id);
    if (index != -1) {
      final newStatus = !categories[index]["status"];
      categories[index]["status"] = newStatus;
      categories.refresh();

      try {
        await _categoryCollection.doc(id).update({"status": newStatus});
      } catch (e) {
        if (kDebugMode) {
          print('Error updating category status in Firestore: $e');
        }
      }
    }
  }
}
