import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_notifier.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/patient/patient_shell.dart';
import '../../features/patient/screens/patient_dashboard.dart';
import '../../features/patient/screens/book_appointment_screen.dart';
import '../../features/patient/screens/doctor_detail_screen.dart';
import '../../features/patient/screens/my_appointments_screen.dart';
import '../../features/patient/screens/medical_records_screen.dart';
import '../../features/patient/screens/patient_profile_screen.dart';
import '../../features/patient/screens/chat_screen.dart';
import '../../features/patient/screens/telemedicine_screen.dart';
import '../../features/patient/screens/find_pharmacy_screen.dart';
import '../../features/patient/screens/notifications_screen.dart';
import '../../features/doctor/doctor_shell.dart';
import '../../features/doctor/screens/doctor_dashboard.dart';
import '../../features/doctor/screens/appointment_management_screen.dart';
import '../../features/doctor/screens/patient_details_screen.dart';
import '../../features/doctor/screens/write_prescription_screen.dart';
import '../../features/doctor/screens/doctor_schedule_screen.dart';
import '../../features/doctor/screens/earnings_screen.dart';
import '../../features/doctor/screens/doctor_profile_screen.dart';
import '../../features/doctor/screens/patient_list_screen.dart';
import '../../features/doctor/screens/doctor_chat_list_screen.dart';
import '../../features/doctor/screens/doctor_notifications_screen.dart';
import '../../features/doctor/screens/doctor_telemedicine_screen.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/manage_doctors_screen.dart';
import '../../features/admin/screens/manage_patients_screen.dart';
import '../../features/admin/screens/admin_appointments_screen.dart';
import '../../features/admin/screens/admin_more_screen.dart';
import '../../features/admin/screens/departments_screen.dart';
import '../../features/admin/screens/staff_management_screen.dart';
import '../../features/admin/screens/billing_screen.dart';
import '../../features/admin/screens/reports_screen.dart';
import '../../features/admin/screens/settings_screen.dart';
import '../../features/admin/screens/admin_profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/' ||
          state.matchedLocation == '/role-selection' ||
          state.matchedLocation.startsWith('/login');

      if (!isLoggedIn && !isLoggingIn) {
        return '/';
      }

      if (isLoggedIn && isLoggingIn) {
        switch (authState.role) {
          case 'patient':
            return '/patient';
          case 'doctor':
            return '/doctor';
          case 'admin':
            return '/admin';
        }
      }

      // Role-based route guarding
      if (isLoggedIn) {
        final loc = state.matchedLocation;
        if (loc.startsWith('/patient') && authState.role != 'patient') {
          return '/${authState.role}';
        }
        if (loc.startsWith('/doctor') && authState.role != 'doctor') {
          return '/${authState.role}';
        }
        if (loc.startsWith('/admin') && authState.role != 'admin') {
          return '/${authState.role}';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        name: 'role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login/:role',
        name: 'login',
        builder: (context, state) {
          final role = state.pathParameters['role'] ?? 'patient';
          return LoginScreen(role: role);
        },
      ),
      // Patient routes
      ShellRoute(
        builder: (context, state, child) => PatientShell(child: child),
        routes: [
          GoRoute(
            path: '/patient',
            name: 'patient-dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PatientDashboard(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/patient/book-appointment',
            name: 'book-appointment',
            pageBuilder: (context, state) {
              final initialSpecialty = state.extra as String? ?? 'All';
              return CustomTransitionPage(
                child: BookAppointmentScreen(initialSpecialty: initialSpecialty),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: '/patient/doctor-detail/:doctorId',
            name: 'doctor-detail',
            pageBuilder: (context, state) {
              final doctorId = state.pathParameters['doctorId'] ?? '';
              return CustomTransitionPage(
                child: DoctorDetailScreen(doctorId: doctorId),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: '/patient/appointments',
            name: 'patient-appointments',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MyAppointmentsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/patient/records',
            name: 'medical-records',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const MedicalRecordsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/patient/profile',
            name: 'patient-profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PatientProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/patient/chat',
            name: 'patient-chat',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ChatScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/patient/telemedicine',
            name: 'telemedicine',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const TelemedicineScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/patient/pharmacy',
            name: 'find-pharmacy',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const FindPharmacyScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/patient/notifications',
            name: 'patient-notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const NotificationsScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
      // Doctor routes
      ShellRoute(
        builder: (context, state, child) => DoctorShell(child: child),
        routes: [
          GoRoute(
            path: '/doctor',
            name: 'doctor-dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorDashboard(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/appointments',
            name: 'doctor-appointments',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AppointmentManagementScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/dashboard',
            name: 'doctor-dashboard-alias',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorDashboard(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/patient-details/:patientId',
            name: 'patient-details',
            pageBuilder: (context, state) {
              final patientId = state.pathParameters['patientId'] ?? '';
              return CustomTransitionPage(
                child: PatientDetailsScreen(patientId: patientId),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: '/doctor/write-prescription/:patientId',
            name: 'write-prescription',
            pageBuilder: (context, state) {
              final patientId = state.pathParameters['patientId'] ?? '';
              return CustomTransitionPage(
                child: WritePrescriptionScreen(patientId: patientId),
                transitionsBuilder: _slideTransition,
              );
            },
          ),
          GoRoute(
            path: '/doctor/prescribe',
            name: 'doctor-prescribe',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const WritePrescriptionScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/chat-list',
            name: 'doctor-chat-list',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorChatListScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/chat',
            name: 'doctor-chat',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ChatScreen(doctorName: 'Patient'),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/schedule',
            name: 'doctor-schedule',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorScheduleScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/earnings',
            name: 'doctor-earnings',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const EarningsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/profile',
            name: 'doctor-profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/patients',
            name: 'doctor-patients',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const PatientListScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/chats',
            name: 'doctor-chats',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorChatListScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/notifications',
            name: 'doctor-notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorNotificationsScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
          GoRoute(
            path: '/doctor/telemedicine',
            name: 'doctor-telemedicine',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DoctorTelemedicineScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),
      // Admin routes
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            name: 'admin-dashboard',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminDashboard(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin-dashboard-alias',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminDashboard(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/doctors',
            name: 'manage-doctors',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ManageDoctorsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/patients',
            name: 'manage-patients',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ManagePatientsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/appointments',
            name: 'admin-appointments',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminAppointmentsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/departments',
            name: 'departments',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DepartmentsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/staff',
            name: 'staff-management',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const StaffManagementScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/billing',
            name: 'billing',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const BillingScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/reports',
            name: 'reports',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const ReportsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/settings',
            name: 'settings',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/profile',
            name: 'admin-profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/admin/more',
            name: 'admin-more',
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const AdminMoreScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
    ],
  );
});

Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
    child: child,
  );
}
