class AdminModel {
  final String id;
  final String email;
  final String password;
  final String role;
  final DateTime? createdAt;

  AdminModel({
    required this.id,
    required this.email,
    required this.password,
    this.role = 'admin',
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return AdminModel(
      id: docId ?? map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'admin',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }
}
