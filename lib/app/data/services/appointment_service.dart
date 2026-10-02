import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/appointment_model.dart';

class AppointmentService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();

  // Fresh empty list: Only real appointments added for this parlor will show
  final allAppointments = <AppointmentModel>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _appointmentsSubscription;

  /// Current Logged-in Parlor ID
  String get currentParlorId {
    final id = _storage.read('parlorId');
    if (id != null && id.toString().trim().isNotEmpty) {
      return id.toString().trim();
    }
    return 'default_parlor';
  }

  /// Sub-collection reference: parlors/{parlorId}/appointments
  CollectionReference<Map<String, dynamic>> get _appointmentsCollection {
    return _firestore
        .collection('parlors')
        .doc(currentParlorId)
        .collection('appointments');
  }

  @override
  void onInit() {
    super.onInit();
    bindAppointmentsStream();
  }

  @override
  void onClose() {
    _appointmentsSubscription?.cancel();
    super.onClose();
  }

  /// Realtime stream for current parlor's appointments
  void bindAppointmentsStream() {
    try {
      _appointmentsSubscription?.cancel();
      _appointmentsSubscription = _appointmentsCollection
          .orderBy('visitingDateTime', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          allAppointments.assignAll(snapshot.docs.map((doc) {
            return AppointmentModel.fromMap(doc.data(), docId: doc.id);
          }).toList());
        },
        onError: (err) {
          if (kDebugMode) {
            print('Firestore appointments stream error: $err');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error setting up appointments stream: $e');
      }
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    allAppointments.add(appointment); // Fast local UI update
    try {
      final docRef = appointment.id.isNotEmpty
          ? _appointmentsCollection.doc(appointment.id)
          : _appointmentsCollection.doc();
      final newApp = appointment.copyWith(id: docRef.id);
      await docRef.set(newApp.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding appointment to Firestore: $e');
      }
    }
  }

  Future<void> updateAppointment(AppointmentModel updatedApp) async {
    final index = allAppointments.indexWhere((app) => app.id == updatedApp.id);
    if (index != -1) {
      allAppointments[index] = updatedApp;
    }
    try {
      await _appointmentsCollection.doc(updatedApp.id).update(updatedApp.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating appointment in Firestore: $e');
      }
    }
  }

  Future<void> deleteAppointment(String id) async {
    allAppointments.removeWhere((app) => app.id == id);
    try {
      await _appointmentsCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting appointment from Firestore: $e');
      }
    }
  }

  /// Delete all sample appointment documents in Firestore
  Future<void> clearAllAppointmentsInFirestore() async {
    try {
      final snapshot = await _appointmentsCollection.get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      allAppointments.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing appointments from Firestore: $e');
      }
    }
  }
}
