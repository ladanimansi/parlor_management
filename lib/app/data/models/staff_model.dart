class StaffModel {
  final String id;
  final String name;
  final String mobileNumber;
  final List<String> specialties;
  final bool status;

  StaffModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.specialties,
    this.status = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'specialties': specialties,
      'status': status,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      status: map['status'] ?? true,
    );
  }

  bool get isAvailable => status;
  String get statusText => status ? 'Available' : 'Busy';

  StaffModel copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    List<String>? specialties,
    bool? status,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      specialties: specialties ?? this.specialties,
      status: status ?? this.status,
    );
  }
}
