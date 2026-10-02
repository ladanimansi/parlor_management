import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/staff_model.dart';

class StaffService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh empty list: Only real data added for this parlor will show
  final allStaff = <StaffModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _staffSubscription;

  /// Current Logged-in Parlor ID (from session or default)
  String get currentParlorId {
    final id = _storage.read('parlorId');
    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
    return 'default_parlor';
  }

  /// Sub-collection reference: parlors/{parlorId}/staff
  CollectionReference<Map<String, dynamic>> get _staffCollection {
    return _firestore
        .collection('parlors')
        .doc(currentParlorId)
        .collection('staff');
  }

  @override
  void onInit() {
    super.onInit();
    bindStaffStream();
  }

  @override
  void onClose() {
    _staffSubscription?.cancel();
    super.onClose();
  }

  /// Bind realtime Firestore listener for the current parlor's staff sub-collection
  void bindStaffStream() {
    try {
      _staffSubscription?.cancel();
      _staffSubscription = _staffCollection.snapshots().listen(
        (snapshot) {
          allStaff.assignAll(snapshot.docs.map((doc) {
            return StaffModel.fromMap(doc.data(), docId: doc.id);
          }).toList());
        },
        onError: (error) {
          if (kDebugMode) {
            print('Firestore staff stream error: $error');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up staff stream: $e');
      }
    }
  }

  /// Add new staff member to current parlor
  Future<void> addStaff(StaffModel staff) async {
    allStaff.add(staff); // Instant local update for fast UI
    try {
      final docRef = staff.id.isNotEmpty
          ? _staffCollection.doc(staff.id)
          : _staffCollection.doc();
      final newStaff = staff.copyWith(id: docRef.id);
      await docRef.set(newStaff.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding staff to Firestore: $e');
      }
    }
  }

  /// Update existing staff in current parlor
  Future<void> updateStaff(StaffModel updatedStaff) async {
    final index = allStaff.indexWhere((s) => s.id == updatedStaff.id);
    if (index != -1) {
      allStaff[index] = updatedStaff;
    }
    try {
      await _staffCollection.doc(updatedStaff.id).update(updatedStaff.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating staff in Firestore: $e');
      }
    }
  }

  /// Delete staff from current parlor
  Future<void> deleteStaff(String id) async {
    allStaff.removeWhere((s) => s.id == id);
    try {
      await _staffCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting staff from Firestore: $e');
      }
    }
  }

  /// Delete all sample staff documents in Firestore for clean start
  Future<void> clearAllStaffInFirestore() async {
    try {
      final snapshot = await _staffCollection.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      allStaff.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing staff from Firestore: $e');
      }
    }
  }
}
