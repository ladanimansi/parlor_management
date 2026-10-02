import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProductItemController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh empty list: Only real items added for this parlor will show
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _itemSubscription;

  String get currentParlorId {
    final id = _storage.read('parlorId');
    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
    return 'default_parlor';
  }

  CollectionReference<Map<String, dynamic>> get _itemCollection {
    return _firestore
        .collection('parlors')
        .doc(currentParlorId)
        .collection('products');
  }

  @override
  void onInit() {
    super.onInit();
    bindItemsStream();
  }

  @override
  void onClose() {
    _itemSubscription?.cancel();
    super.onClose();
  }

  void bindItemsStream() {
    try {
      _itemSubscription?.cancel();
      _itemSubscription = _itemCollection.snapshots().listen(
        (snapshot) {
          items.assignAll(snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
        },
        onError: (err) {
          if (kDebugMode) {
            print('Firestore services stream error: $err');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up services stream: $e');
      }
    }
  }

  void addItem(String name, String price, String category) async {
    if (name.trim().isEmpty || price.trim().isEmpty || category.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newItem = {
      "id": id,
      "name": name.trim(),
      "price": price.trim(),
      "category": category,
      "status": true,
    };
    items.add(newItem);

    try {
      await _itemCollection.doc(id).set(newItem);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding item to Firestore: $e');
      }
    }
  }

  void editItem(String id, String newName, String newPrice, String newCategory) async {
    if (newName.trim().isEmpty || newPrice.trim().isEmpty || newCategory.isEmpty) return;
    final index = items.indexWhere((item) => item["id"] == id);
    if (index != -1) {
      items[index]["name"] = newName.trim();
      items[index]["price"] = newPrice.trim();
      items[index]["category"] = newCategory;
      items.refresh();
    }

    try {
      await _itemCollection.doc(id).update({
        "name": newName.trim(),
        "price": newPrice.trim(),
        "category": newCategory,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating item in Firestore: $e');
      }
    }
  }

  void deleteItem(String id) async {
    items.removeWhere((item) => item["id"] == id);
    try {
      await _itemCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting item from Firestore: $e');
      }
    }
  }
}
