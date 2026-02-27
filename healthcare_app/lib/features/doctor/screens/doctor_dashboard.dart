import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../mock_data/mock_doctors.dart';

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final doctor = mockDoctors.firstWhere(
      (d) => d.id == auth.userId,
      orElse: () => mockDoctors.first,
    );

    final todaysAppointments = mockAppointments
        .where((a) =>
            a.doctorId == doctor.id &&
            DateFormat('yyyy-MM-dd').format(a.date) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .toList();

    final pendingAppts = mockAppointments
        .where((a) => a.doctorId == doctor.id && a.status == 'Pending')
        .toList();

    final completedToday = todaysAppointments
        .where((a) => a.status == 'Completed')
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good Morning',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400)),
            Text(doctor.name,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () => context.push('/doctor/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    value: '${todaysAppointments.length}',
                    label: "Today's Appts",
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$completedToday',
                    label: 'Completed',
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.pending_actions,
                    value: '${pendingAppts.length}',
                    label: 'Pending',
                    color: AppTheme.warningAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.people,
                    value: '${doctor.patientCount}',
                    label: 'Total Patients',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.star,
                    value: doctor.rating.toStringAsFixed(1),
                    label: 'Rating',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.attach_money,
                    value: '\$${(doctor.consultationFee * todaysAppointments.length).toInt()}',
                    label: "Today's Earning",
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Next Appointment
            if (todaysAppointments.isNotEmpty) ...[
              const Text('Next Appointment',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              _NextAppointmentCard(appointment: todaysAppointments.first),
              const SizedBox(height: 20),
            ],

            // Pending Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Requests',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton(
                  onPressed: () => context.go('/doctor/appointments'),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (pendingAppts.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle,
                            size: 40, color: AppTheme.successGreen),
                        const SizedBox(height: 8),
                        const Text('No pending requests'),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...pendingAppts.take(3).map((appt) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: MockAvatarWidget(
                        name: appt.patientName, size: 40, avatarUrl: appt.patientAvatar),
                    title: Text(appt.patientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      '${DateFormat('MMM dd').format(appt.date)} • ${appt.timeSlot} • ${appt.type}',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: AppTheme.successGreen),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Appointment accepted')),
                            );
                          },
                          iconSize: 28,
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel,
                              color: AppTheme.errorRed),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Appointment declined')),
                            );
                          },
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
            // Quick Actions
            const Text('Quick Actions',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _QuickAction(
                  icon: Icons.edit_note,
                  label: 'Prescribe',
                  color: AppTheme.primaryBlue,
                  onTap: () => context.push('/doctor/prescribe'),
                ),
                _QuickAction(
                  icon: Icons.schedule,
                  label: 'Schedule',
                  color: Colors.teal,
                  onTap: () => context.go('/doctor/schedule'),
                ),
                _QuickAction(
                  icon: Icons.account_balance_wallet,
                  label: 'Earnings',
                  color: Colors.orange,
                  onTap: () => context.push('/doctor/earnings'),
                ),
                _QuickAction(
                  icon: Icons.chat_bubble_outline,
                  label: 'Messages',
                  color: Colors.purple,
                  onTap: () => context.push('/doctor/chat-list'),
                ),
                _QuickAction(
                  icon: Icons.videocam_outlined,
                  label: 'Telemedicine',
                  color: AppTheme.successGreen,
                  onTap: () {},
                ),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  color: Colors.indigo,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final dynamic appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryBlue,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            MockAvatarWidget(name: appointment.patientName, size: 50, avatarUrl: appointment.patientAvatar),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appointment.patientName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(
                    '${appointment.timeSlot} • ${appointment.type}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.notes.isNotEmpty ? appointment.notes : appointment.type,
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Start',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                StatusChip(status: appointment.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  Color get _lighter {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: color.withValues(alpha: 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, _lighter],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
