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
  final String? allocatedStaffId;
  final String? allocatedStaffName;
  final String bookingType;

  // New demographic & walk-in variables
  final int? clientAge;
  final String? clientGender;
  final String? clientOtherInfo;
  final String? selectedProducts;
  final String paymentStatus; // 'Pending', 'Partial', 'Paid'
  final List<ServiceItemAllocation> serviceAllocations;

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
    this.allocatedStaffId,
    this.allocatedStaffName,
    this.bookingType = 'Walk in orders',
    this.clientAge,
    this.clientGender,
    this.clientOtherInfo,
    this.selectedProducts,
    this.paymentStatus = 'Pending',
    this.serviceAllocations = const [],
  });

  List<ServiceItemAllocation> get effectiveServiceAllocations {
    if (serviceAllocations.isNotEmpty) {
      return serviceAllocations;
    }

    final services = serviceName.isNotEmpty
        ? serviceName.split(',')
        : (category.isNotEmpty ? category.split(',') : ['General Service']);

    final itemPrice = amount / (services.isEmpty ? 1 : services.length);

    return services.asMap().entries.map((entry) {
      final idx = entry.key;
      final sName = entry.value.trim();
      return ServiceItemAllocation(
        serviceId: 's_alloc_${id}_$idx',
        serviceName: sName.isEmpty ? 'Service ${idx + 1}' : sName,
        price: itemPrice,
        staffId: allocatedStaffId,
        staffName: allocatedStaffName,
        status: status == 'Completed' ? 'Completed' : (allocatedStaffId != null ? 'Running' : 'Waiting'),
      );
    }).toList();
  }

  String get statusKey {
    switch (status.toLowerCase()) {
      case 'advance':
      case 'advance booked':
        return 'advance_booked';
      case 'confirm':
        return 'confirm';
      case 'inprogress':
        return 'in_progress';
      case 'completed':
        return 'completed';
      case 'cancelled':
        return 'cancelled';
      case 'waiting':
        return 'waiting';
      default:
        return 'inquiry';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'advance':
      case 'advance booked':
        return Colors.teal;
      case 'confirm':
        return Colors.green;
      case 'inprogress':
        return Colors.orange;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      case 'waiting':
        return Colors.blue;
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
      'allocatedStaffId': allocatedStaffId,
      'allocatedStaffName': allocatedStaffName,
      'bookingType': bookingType,
      'clientAge': clientAge,
      'clientGender': clientGender,
      'clientOtherInfo': clientOtherInfo,
      'selectedProducts': selectedProducts,
      'paymentStatus': paymentStatus,
      'serviceAllocations': serviceAllocations.map((x) => x.toMap()).toList(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AppointmentModel(
      id: docId ?? map['id'] ?? '',
      clientName: map['clientName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      serviceName: map['serviceName'],
      category: map['category'] ?? 'General',
      visitingDateTime: DateTime.parse(map['visitingDateTime'] ?? map['dateTime']),
      bookingDateTime: DateTime.parse(map['bookingDateTime'] ?? map['dateTime']),
      status: map['status'],
      amount: map['amount']?.toDouble() ?? 0.0,
      notes: map['notes'],
      referenceBy: map['referenceBy'],
      allocatedStaffId: map['allocatedStaffId'],
      allocatedStaffName: map['allocatedStaffName'],
      bookingType: map['bookingType'] ?? 'Walk in orders',
      clientAge: map['clientAge'] != null ? int.tryParse(map['clientAge'].toString()) : null,
      clientGender: map['clientGender'],
      clientOtherInfo: map['clientOtherInfo'],
      selectedProducts: map['selectedProducts'],
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      serviceAllocations: map['serviceAllocations'] != null
          ? List<ServiceItemAllocation>.from(
              (map['serviceAllocations'] as List).map((x) => ServiceItemAllocation.fromMap(x)))
          : [],
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? clientName,
    String? mobileNumber,
    String? serviceName,
    String? category,
    DateTime? visitingDateTime,
    DateTime? bookingDateTime,
    String? status,
    double? amount,
    String? notes,
    String? referenceBy,
    String? allocatedStaffId,
    String? allocatedStaffName,
    String? bookingType,
    int? clientAge,
    String? clientGender,
    String? clientOtherInfo,
    String? selectedProducts,
    String? paymentStatus,
    List<ServiceItemAllocation>? serviceAllocations,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      serviceName: serviceName ?? this.serviceName,
      category: category ?? this.category,
      visitingDateTime: visitingDateTime ?? this.visitingDateTime,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      referenceBy: referenceBy ?? this.referenceBy,
      allocatedStaffId: allocatedStaffId ?? this.allocatedStaffId,
      allocatedStaffName: allocatedStaffName ?? this.allocatedStaffName,
      bookingType: bookingType ?? this.bookingType,
      clientAge: clientAge ?? this.clientAge,
      clientGender: clientGender ?? this.clientGender,
      clientOtherInfo: clientOtherInfo ?? this.clientOtherInfo,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      serviceAllocations: serviceAllocations ?? this.serviceAllocations,
    );
  }
}

class ServiceItemAllocation {
  final String serviceId;
  final String serviceName;
  final double price;
  final String? staffId;
  final String? staffName;
  final String status; // 'Waiting', 'Running', 'Completed'

  ServiceItemAllocation({
    required this.serviceId,
    required this.serviceName,
    required this.price,
    this.staffId,
    this.staffName,
    this.status = 'Waiting',
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'staffId': staffId,
      'staffName': staffName,
      'status': status,
    };
  }

  factory ServiceItemAllocation.fromMap(Map<String, dynamic> map) {
    return ServiceItemAllocation(
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      staffId: map['staffId'],
      staffName: map['staffName'],
      status: map['status'] ?? 'Waiting',
    );
  }

  ServiceItemAllocation copyWith({
    String? serviceId,
    String? serviceName,
    double? price,
    String? staffId,
    String? staffName,
    String? status,
  }) {
    return ServiceItemAllocation(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      status: status ?? this.status,
    );
  }
}
