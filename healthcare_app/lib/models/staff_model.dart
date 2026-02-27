class StaffModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // Nurse, Receptionist, Lab Technician, Pharmacist
  final String department;
  final bool isActive;
  final DateTime joinDate;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    this.isActive = true,
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  StaffModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? department,
    bool? isActive,
    DateTime? joinDate,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'department': department,
        'isActive': isActive,
        'joinDate': joinDate.toIso8601String(),
      };

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        department: json['department'] as String,
        isActive: json['isActive'] as bool? ?? true,
        joinDate: DateTime.parse(json['joinDate'] as String),
      );
}
