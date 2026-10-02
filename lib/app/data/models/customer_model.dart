class CustomerModel {
  final String id;
  final String name;
  final String mobileNumber;
  final int? age;
  final String? gender;
  final String? otherInfo;

  CustomerModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    this.age,
    this.gender,
    this.otherInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'age': age,
      'gender': gender,
      'otherInfo': otherInfo,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CustomerModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
      gender: map['gender'],
      otherInfo: map['otherInfo'],
    );
  }
}
