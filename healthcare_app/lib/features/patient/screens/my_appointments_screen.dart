import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/appointment_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../features/auth/auth_notifier.dart';

class MyAppointmentsScreen extends ConsumerWidget {
  const MyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final all = mockAppointments
        .where((a) => a.patientId == auth.userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final upcoming = all.where((a) => a.isUpcoming).toList();
    final completed = all.where((a) => a.isCompleted).toList();
    final cancelled = all.where((a) => a.isCancelled).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Appointments'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'Completed (${completed.length})'),
              Tab(text: 'Cancelled (${cancelled.length})'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: TabBarView(
          children: [
            _AppointmentList(appointments: upcoming),
            _AppointmentList(appointments: completed),
            _AppointmentList(appointments: cancelled),
          ],
        ),
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List appointments;
  const _AppointmentList({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'No Appointments',
        message: 'You don\'t have any appointments in this category.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        return AppointmentCard(
          doctorName: apt.doctorName,
          specialty: apt.doctorSpecialty,
          date: DateFormat('MMM dd, yyyy').format(apt.date),
          time: apt.timeSlot,
          status: apt.status,
          type: apt.type,
          doctorAvatarUrl: apt.doctorAvatar,
          onCancel: apt.status == 'Confirmed' || apt.status == 'Pending'
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment cancelled')),
                  );
                }
              : null,
          onJoin: () {},
        );
      },
    );
  }
}
