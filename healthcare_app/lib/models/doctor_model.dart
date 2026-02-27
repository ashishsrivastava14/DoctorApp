class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final String bio;
  final String education;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final int patientCount;
  final double consultationFee;
  final String avatarUrl;
  final bool isAvailable;
  final List<String> availableDays;
  final List<String> availableSlots;
  final String hospitalName;
  final String address;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.bio,
    required this.education,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.patientCount,
    required this.consultationFee,
    this.avatarUrl = '',
    this.isAvailable = true,
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.availableSlots = const [],
    this.hospitalName = 'City General Hospital',
    this.address = '',
  });

  DoctorModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    String? bio,
    String? education,
    int? experienceYears,
    double? rating,
    int? reviewCount,
    int? patientCount,
    double? consultationFee,
    String? avatarUrl,
    bool? isAvailable,
    List<String>? availableDays,
    List<String>? availableSlots,
    String? hospitalName,
    String? address,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      education: education ?? this.education,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      patientCount: patientCount ?? this.patientCount,
      consultationFee: consultationFee ?? this.consultationFee,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      availableDays: availableDays ?? this.availableDays,
      availableSlots: availableSlots ?? this.availableSlots,
      hospitalName: hospitalName ?? this.hospitalName,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'bio': bio,
      'education': education,
      'experienceYears': experienceYears,
      'rating': rating,
      'reviewCount': reviewCount,
      'patientCount': patientCount,
      'consultationFee': consultationFee,
      'avatarUrl': avatarUrl,
      'isAvailable': isAvailable,
      'availableDays': availableDays,
      'availableSlots': availableSlots,
      'hospitalName': hospitalName,
      'address': address,
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      specialty: json['specialty'] as String,
      bio: json['bio'] as String,
      education: json['education'] as String,
      experienceYears: json['experienceYears'] as int,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      patientCount: json['patientCount'] as int,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      avatarUrl: json['avatarUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      availableDays: List<String>.from(json['availableDays'] ?? []),
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      hospitalName: json['hospitalName'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }
}
