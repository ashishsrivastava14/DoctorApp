class PrescriptionModel {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final DateTime date;
  final String diagnosis;
  final List<MedicineItem> medicines;
  final String notes;
  final DateTime? followUpDate;

  PrescriptionModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.diagnosis,
    required this.medicines,
    this.notes = '',
    this.followUpDate,
  });

  PrescriptionModel copyWith({
    String? id,
    String? appointmentId,
    String? doctorId,
    String? doctorName,
    String? patientId,
    String? patientName,
    DateTime? date,
    String? diagnosis,
    List<MedicineItem>? medicines,
    String? notes,
    DateTime? followUpDate,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      medicines: medicines ?? this.medicines,
      notes: notes ?? this.notes,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'diagnosis': diagnosis,
      'medicines': medicines.map((m) => m.toJson()).toList(),
      'notes': notes,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      date: DateTime.parse(json['date'] as String),
      diagnosis: json['diagnosis'] as String,
      medicines: (json['medicines'] as List)
          .map((m) => MedicineItem.fromJson(m))
          .toList(),
      notes: json['notes'] as String? ?? '',
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'] as String)
          : null,
    );
  }
}

class MedicineItem {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  MedicineItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = '',
  });

  MedicineItem copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
  }) {
    return MedicineItem(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
    };
  }

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
      instructions: json['instructions'] as String? ?? '',
    );
  }
}
