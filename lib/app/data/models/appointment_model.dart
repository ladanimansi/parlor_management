import 'package:flutter/material.dart';

class AppointmentModel {
  final String id;
  final String clientName;
  final String mobileNumber;
  final String serviceName;
  final String category;
  final DateTime visitingDateTime;
  final DateTime bookingDateTime;
  final String status;
  final double amount;
  final String? notes;
  final String? referenceBy;

  AppointmentModel({
    required this.id,
    required this.clientName,
    required this.mobileNumber,
    required this.serviceName,
    required this.category,
    required this.visitingDateTime,
    required this.bookingDateTime,
    required this.status,
    required this.amount,
    this.notes,
    this.referenceBy,
  });

  String get statusKey {
    switch (status.toLowerCase()) {
      case 'confirm':
        return 'confirm';
      case 'inprogress':
        return 'in_progress';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      default:
        return 'inquiry';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirm':
        return Colors.green;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'mobileNumber': mobileNumber,
      'serviceName': serviceName,
      'category': category,
      'visitingDateTime': visitingDateTime.toIso8601String(),
      'bookingDateTime': bookingDateTime.toIso8601String(),
      'status': status,
      'amount': amount,
      'notes': notes,
      'referenceBy': referenceBy,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      clientName: map['clientName'],
      mobileNumber: map['mobileNumber'] ?? '',
      serviceName: map['serviceName'],
      category: map['category'] ?? 'General',
      visitingDateTime: DateTime.parse(map['visitingDateTime'] ?? map['dateTime']),
      bookingDateTime: DateTime.parse(map['bookingDateTime'] ?? map['dateTime']),
      status: map['status'],
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'],
      referenceBy: map['referenceBy'],
    );
  }
}
