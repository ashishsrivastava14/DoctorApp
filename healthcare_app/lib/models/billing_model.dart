class BillingModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final String appointmentId;
  final DateTime date;
  final double amount;
  final String status; // Paid, Pending, Overdue
  final String paymentMethod;
  final String description;

  BillingModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.appointmentId,
    required this.date,
    required this.amount,
    required this.status,
    this.paymentMethod = 'Card',
    this.description = 'Consultation Fee',
  });

  BillingModel copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    String? appointmentId,
    DateTime? date,
    double? amount,
    String? status,
    String? paymentMethod,
    String? description,
  }) {
    return BillingModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      appointmentId: appointmentId ?? this.appointmentId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'date': date.toIso8601String(),
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'description': description,
    };
  }

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      appointmentId: json['appointmentId'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String? ?? 'Card',
      description: json['description'] as String? ?? 'Consultation Fee',
    );
  }
}
