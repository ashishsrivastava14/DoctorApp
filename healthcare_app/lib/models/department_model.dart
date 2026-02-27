class DepartmentModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int doctorCount;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.doctorCount = 0,
    this.isActive = true,
  });

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? doctorCount,
    bool? isActive,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      doctorCount: doctorCount ?? this.doctorCount,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'doctorCount': doctorCount,
      'isActive': isActive,
    };
  }

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      doctorCount: json['doctorCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
