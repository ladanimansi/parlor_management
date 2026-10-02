import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/customer_model.dart';

class CustomerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh empty list: Only real customers added for this parlor will show
  final allCustomers = <CustomerModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _customersSubscription;

  /// Current Logged-in Parlor ID
  String get currentParlorId {
    final id = _storage.read('parlorId');
    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
    return 'default_parlor';
  }

  /// Sub-collection reference: parlors/{parlorId}/customers
  CollectionReference<Map<String, dynamic>> get _customersCollection {
    return _firestore
        .collection('parlors')
        .doc(currentParlorId)
        .collection('customers');
  }

  @override
  void onInit() {
    super.onInit();
    bindCustomersStream();
  }

  @override
  void onClose() {
    _customersSubscription?.cancel();
    super.onClose();
  }

  /// Realtime stream for current parlor's customers
  void bindCustomersStream() {
    try {
      _customersSubscription?.cancel();
      _customersSubscription = _customersCollection.snapshots().listen(
        (snapshot) {
          allCustomers.assignAll(snapshot.docs.map((doc) {
            return CustomerModel.fromMap(doc.data(), docId: doc.id);
          }).toList());
        },
        onError: (err) {
          if (kDebugMode) {
            print('Firestore customers stream error: $err');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up customers stream: $e');
      }
    }
  }

  CustomerModel? getCustomerByMobile(String mobile) {
    final cleanMobile = mobile.replaceAll(RegExp(r'\D'), '');
    if (cleanMobile.length < 10) return null;
    return allCustomers.firstWhereOrNull(
      (c) => c.mobileNumber.replaceAll(RegExp(r'\D'), '') == cleanMobile,
    );
  }

  Future<void> registerCustomer(CustomerModel customer) async {
    final cleanTarget = customer.mobileNumber.replaceAll(RegExp(r'\D'), '');
    final index = allCustomers.indexWhere(
      (c) => c.mobileNumber.replaceAll(RegExp(r'\D'), '') == cleanTarget,
    );
    if (index != -1) {
      allCustomers[index] = customer;
    } else {
      allCustomers.add(customer);
    }

    try {
      final docId = cleanTarget.isNotEmpty ? cleanTarget : customer.id;
      await _customersCollection.doc(docId).set(customer.toMap(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error registering customer in Firestore: $e');
      }
    }
  }

  /// Delete all sample customer documents in Firestore
  Future<void> clearAllCustomersInFirestore() async {
    try {
      final snapshot = await _customersCollection.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      allCustomers.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing customers from Firestore: $e');
      }
    }
  }
}
