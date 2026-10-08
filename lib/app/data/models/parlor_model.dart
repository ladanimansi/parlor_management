class ParlorModel {
  final String id;
  final String parlorName;
  final String ownerName;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String city;
  final String role;
  final bool isActive;
  final List<String> allowedFlowTypes;
  final DateTime? createdAt;

  ParlorModel({
    required this.id,
    required this.parlorName,
    required this.ownerName,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    this.city = '',
    this.role = 'client',
    this.isActive = true,
    this.allowedFlowTypes = const [
      'Walk in orders',
      'Advance appoinment',
      'Bridal Orders',
      'Package',
      'Home service',
    ],
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parlorName': parlorName,
      'ownerName': ownerName,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'city': city,
      'role': role,
      'isActive': isActive,
      'allowedFlowTypes': allowedFlowTypes,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory ParlorModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ParlorModel(
      id: docId ?? map['id'] ?? '',
      parlorName: map['parlorName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      role: map['role'] ?? 'client',
      isActive: map['isActive'] ?? true,
      allowedFlowTypes: map['allowedFlowTypes'] != null
          ? List<String>.from(map['allowedFlowTypes'])
          : const [
              'Walk in orders',
              'Advance appoinment',
              'Bridal Orders',
              'Package',
              'Home service',
            ],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  ParlorModel copyWith({
    String? id,
    String? parlorName,
    String? ownerName,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? city,
    String? role,
    bool? isActive,
    List<String>? allowedFlowTypes,
    DateTime? createdAt,
  }) {
    return ParlorModel(
      id: id ?? this.id,
      parlorName: parlorName ?? this.parlorName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      allowedFlowTypes: allowedFlowTypes ?? this.allowedFlowTypes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
