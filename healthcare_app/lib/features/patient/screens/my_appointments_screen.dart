import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/appointment_card.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../models/appointment_model.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../patient/screens/chat_screen.dart';

class MyAppointmentsScreen extends ConsumerStatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  ConsumerState<MyAppointmentsScreen> createState() =>
      _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState
    extends ConsumerState<MyAppointmentsScreen> {
  late List<AppointmentModel> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = mockAppointments.toList();
  }

  void _cancelAppointment(AppointmentModel appt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: Text(
          'Cancel appointment with ${appt.doctorName} on '
          '${DateFormat('MMM dd, yyyy').format(appt.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                final idx =
                    _appointments.indexWhere((a) => a.id == appt.id);
                if (idx != -1) {
                  _appointments[idx] =
                      _appointments[idx].copyWith(status: 'Cancelled');
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Appointment cancelled')),
              );
            },
            child: const Text('Cancel Appointment',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _rescheduleDialog(AppointmentModel appt) {
    final slots = [
      '09:00 AM', '10:00 AM', '11:00 AM',
      '02:00 PM', '03:00 PM', '04:00 PM',
    ];
    String selected = appt.timeSlot;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Reschedule Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Doctor: ${appt.doctorName}',
                  style:
                      const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              Text('Select new time slot:',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: slots
                    .map((s) => ChoiceChip(
                          label: Text(s,
                              style:
                                  const TextStyle(fontSize: 12)),
                          selected: selected == s,
                          selectedColor: AppTheme.primaryBlue
                              .withValues(alpha: 0.15),
                          onSelected: (_) =>
                              setS(() => selected = s),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  final idx = _appointments
                      .indexWhere((a) => a.id == appt.id);
                  if (idx != -1) {
                    _appointments[idx] = _appointments[idx]
                        .copyWith(timeSlot: selected);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Rescheduled to $selected')),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _viewDetails(AppointmentModel appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Appointment Details',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _AptDetailRow(
                icon: Icons.person,
                label: 'Doctor',
                value: appt.doctorName),
            _AptDetailRow(
                icon: Icons.medical_services,
                label: 'Specialty',
                value: appt.doctorSpecialty),
            _AptDetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormat('EEEE, MMM dd, yyyy')
                    .format(appt.date)),
            _AptDetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: appt.timeSlot),
            _AptDetailRow(
                icon: appt.type == 'Online'
                    ? Icons.videocam
                    : Icons.local_hospital,
                label: 'Type',
                value: appt.type),
            _AptDetailRow(
                icon: Icons.monetization_on,
                label: 'Fee',
                value: '\$${appt.fee.toStringAsFixed(0)}'),
            _AptDetailRow(
                icon: Icons.info_outline,
                label: 'Status',
                value: appt.status,
                valueColor: _statusColor(appt.status)),
            if (appt.notes.isNotEmpty)
              _AptDetailRow(
                  icon: Icons.notes,
                  label: 'Notes',
                  value: appt.notes),
            const SizedBox(height: 8),
            if (appt.status == 'Confirmed' ||
                appt.status == 'Pending') ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16),
                      label: const Text('Cancel'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(
                              color: AppTheme.errorRed)),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _cancelAppointment(appt);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon:
                          const Icon(Icons.schedule, size: 16),
                      label: const Text('Reschedule'),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _rescheduleDialog(appt);
                      },
                    ),
                  ),
                ],
              ),
              if (appt.type == 'Online') ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.videocam, size: 16),
                    label: const Text('Join Online Consultation'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            doctorName: appt.doctorName,
                            doctorAvatarUrl: appt.doctorAvatar,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Confirmed':
        return AppTheme.successGreen;
      case 'Pending':
        return AppTheme.warningAmber;
      case 'Completed':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final all = _appointments
        .where((a) =>
            a.patientId == auth.userId ||
            a.patientId == 'patient_1')
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
            _buildList(upcoming),
            _buildList(completed),
            _buildList(cancelled),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> appts) {
    if (appts.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: 'No Appointments',
        message:
            'You don\'t have any appointments in this category.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appts.length,
      itemBuilder: (context, index) {
        final apt = appts[index];
        return AppointmentCard(
          doctorName: apt.doctorName,
          specialty: apt.doctorSpecialty,
          date: DateFormat('MMM dd, yyyy').format(apt.date),
          time: apt.timeSlot,
          status: apt.status,
          type: apt.type,
          doctorAvatarUrl: apt.doctorAvatar,
          onTap: () => _viewDetails(apt),
          onCancel:
              apt.status == 'Confirmed' || apt.status == 'Pending'
                  ? () => _cancelAppointment(apt)
                  : null,
          onReschedule:
              apt.status == 'Confirmed' || apt.status == 'Pending'
                  ? () => _rescheduleDialog(apt)
                  : null,
          onJoin: apt.type == 'Online' &&
                  (apt.status == 'Confirmed' ||
                      apt.status == 'Pending')
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        doctorName: apt.doctorName,
                        doctorAvatarUrl: apt.doctorAvatar,
                      ),
                    ),
                  )
              : null,
        );
      },
    );
  }
}

class _AptDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _AptDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryBlue),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: valueColor)),
          ),
        ],
      ),
    );
  }
}
