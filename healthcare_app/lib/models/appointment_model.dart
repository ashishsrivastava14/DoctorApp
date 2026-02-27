class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorAvatar;
  final String patientId;
  final String patientName;
  final String patientAvatar;
  final DateTime date;
  final String timeSlot;
  final String status; // Pending, Confirmed, Completed, Cancelled
  final String type; // In Person, Online
  final double fee;
  final String notes;
  final String? prescriptionId;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    this.doctorAvatar = '',
    required this.patientId,
    required this.patientName,
    this.patientAvatar = '',
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.type,
    required this.fee,
    this.notes = '',
    this.prescriptionId,
  });

  bool get isUpcoming =>
      date.isAfter(DateTime.now()) &&
      (status == 'Confirmed' || status == 'Pending');
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? doctorAvatar,
    String? patientId,
    String? patientName,
    String? patientAvatar,
    DateTime? date,
    String? timeSlot,
    String? status,
    String? type,
    double? fee,
    String? notes,
    String? prescriptionId,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      doctorAvatar: doctorAvatar ?? this.doctorAvatar,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAvatar: patientAvatar ?? this.patientAvatar,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      type: type ?? this.type,
      fee: fee ?? this.fee,
      notes: notes ?? this.notes,
      prescriptionId: prescriptionId ?? this.prescriptionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorAvatar': doctorAvatar,
      'patientId': patientId,
      'patientName': patientName,
      'patientAvatar': patientAvatar,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status,
      'type': type,
      'fee': fee,
      'notes': notes,
      'prescriptionId': prescriptionId,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      doctorAvatar: json['doctorAvatar'] as String? ?? '',
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientAvatar: json['patientAvatar'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      timeSlot: json['timeSlot'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      fee: (json['fee'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      prescriptionId: json['prescriptionId'] as String?,
    );
  }
}
