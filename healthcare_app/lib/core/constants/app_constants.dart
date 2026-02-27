class AppConstants {
  static const String appName = 'HealthCare';
  static const String appTagline = 'Your Health, Our Priority';
  static const String appDescription =
      'Book Doctors. Check Reports. Stay Healthy.';

  // Roles
  static const String roleDoctor = 'doctor';
  static const String rolePatient = 'patient';
  static const String roleAdmin = 'admin';

  // Mock credentials
  static const String doctorEmail = 'doctor@healthcare.com';
  static const String doctorPassword = 'doctor123';
  static const String patientEmail = 'patient@healthcare.com';
  static const String patientPassword = 'patient123';
  static const String adminEmail = 'admin@healthcare.com';
  static const String adminPassword = 'admin123';

  // Specialties
  static const List<String> specialties = [
    'Neurologist',
    'Cardiologist',
    'Dermatologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Gynecologist',
    'Ophthalmologist',
    'ENT Specialist',
    'General Physician',
  ];

  static const List<String> specialtyIcons = [
    '🧠',
    '❤️',
    '🩺',
    '🦴',
    '👶',
    '🧠',
    '👩',
    '👁️',
    '👂',
    '🏥',
  ];

  // Appointment statuses
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';
  static const String statusRescheduled = 'Rescheduled';

  // Payment statuses
  static const String paymentPaid = 'Paid';
  static const String paymentPending = 'Pending';
  static const String paymentOverdue = 'Overdue';

  // Appointment Types
  static const String typeInPerson = 'In Person';
  static const String typeOnline = 'Online';

  // Time slots
  static const List<String> timeSlots = [
    '08:00 AM', '08:30 AM', '09:00 AM', '09:30 AM',
    '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '01:00 PM', '01:30 PM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
    '07:00 PM', '07:30 PM',
  ];

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];
}
