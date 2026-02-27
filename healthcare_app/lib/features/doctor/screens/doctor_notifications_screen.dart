import 'package:flutter/material.dart';
import '../../patient/screens/notifications_screen.dart';

class DoctorNotificationsScreen extends StatelessWidget {
  const DoctorNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsScreen(role: 'doctor');
  }
}
