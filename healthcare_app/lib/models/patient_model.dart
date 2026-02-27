class PatientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String address;
  final String avatarUrl;
  final List<String> allergies;
  final String emergencyContact;
  final String emergencyPhone;
  final double height; // cm
  final double weight; // kg

  PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    this.address = '',
    this.avatarUrl = '',
    this.allergies = const [],
    this.emergencyContact = '',
    this.emergencyPhone = '',
    this.height = 170,
    this.weight = 70,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  double get bmi => weight / ((height / 100) * (height / 100));

  PatientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? address,
    String? avatarUrl,
    List<String>? allergies,
    String? emergencyContact,
    String? emergencyPhone,
    double? height,
    double? weight,
  }) {
    return PatientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'avatarUrl': avatarUrl,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'height': height,
      'weight': weight,
    };
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      bloodGroup: json['bloodGroup'] as String,
      address: json['address'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      allergies: List<String>.from(json['allergies'] ?? []),
      emergencyContact: json['emergencyContact'] as String? ?? '',
      emergencyPhone: json['emergencyPhone'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble() ?? 170,
      weight: (json['weight'] as num?)?.toDouble() ?? 70,
    );
  }
}
