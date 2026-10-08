import 'package:flutter/material.dart';

class FlowTypeItem {
  final String id;
  final String name;
  final String labelKey;
  final IconData icon;
  final String description;

  const FlowTypeItem({
    required this.id,
    required this.name,
    required this.labelKey,
    required this.icon,
    required this.description,
  });
}

class FlowTypeConstants {
  static const String walkInOrders = 'Walk in orders';
  static const String advanceAppointment = 'Advance appoinment';
  static const String bridalOrders = 'Bridal Orders';
  static const String package = 'Package';
  static const String homeService = 'Home service';

  static const List<FlowTypeItem> allFlowTypes = [
    FlowTypeItem(
      id: 'walk_in_orders',
      name: walkInOrders,
      labelKey: 'walk_in_orders',
      icon: Icons.directions_walk,
      description: 'Quick walk-in / instant billing orders',
    ),
    FlowTypeItem(
      id: 'advance_appointment',
      name: advanceAppointment,
      labelKey: 'advance_appointment',
      icon: Icons.calendar_month,
      description: 'Advance scheduled appointments with visiting time',
    ),
    FlowTypeItem(
      id: 'bridal_orders',
      name: bridalOrders,
      labelKey: 'bridal_orders',
      icon: Icons.auto_awesome,
      description: 'Special bridal packages and pre-bookings',
    ),
    FlowTypeItem(
      id: 'package',
      name: package,
      labelKey: 'package',
      icon: Icons.card_membership,
      description: 'Custom beauty service packages',
    ),
    FlowTypeItem(
      id: 'home_service',
      name: homeService,
      labelKey: 'home_service',
      icon: Icons.home,
      description: 'Doorstep home service appointments',
    ),
  ];

  static List<String> get allFlowTypeNames => [
        walkInOrders,
        advanceAppointment,
        bridalOrders,
        package,
        homeService,
      ];

  /// Checks if a given flow type name matches allowed rights
  static bool isAllowed(List<String> allowedList, String typeName) {
    if (allowedList.isEmpty) return true;
    final lower = typeName.trim().toLowerCase();
    return allowedList.any((item) {
      final itemLower = item.trim().toLowerCase();
      if (itemLower == lower) return true;
      if (itemLower.contains('advance') && lower.contains('advance')) return true;
      return false;
    });
  }
}
