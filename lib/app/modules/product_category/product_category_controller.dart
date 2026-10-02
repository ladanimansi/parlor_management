import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProductCategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh empty list: Only real categories added for this parlor will show
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _categorySubscription;

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

  @override
  void onInit() {
    super.onInit();
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
          categories.assignAll(snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
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
