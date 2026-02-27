import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../../mock_data/mock_appointments.dart';

class AppointmentManagementScreen extends ConsumerStatefulWidget {
  const AppointmentManagementScreen({super.key});

  @override
  ConsumerState<AppointmentManagementScreen> createState() =>
      _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState
    extends ConsumerState<AppointmentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final doctorAppts = mockAppointments
        .where((a) => a.doctorId == auth.userId || a.doctorId == 'doc_1')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Type filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'In Person', 'Online'].map((t) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    selected: _filterType == t,
                    selectedColor:
                        AppTheme.primaryBlue.withValues(alpha: 0.15),
                    onSelected: (_) => setState(() => _filterType = t),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'all')),
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'Pending')),
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'Confirmed')),
                _AppointmentList(
                    appointments:
                        _applyFilter(doctorAppts, 'Completed')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _applyFilter(List<dynamic> appts, String status) {
    var filtered = status == 'all'
        ? appts
        : appts.where((a) => a.status == status).toList();
    if (_filterType != 'All') {
      filtered =
          filtered.where((a) => a.type == _filterType).toList();
    }
    return filtered;
  }
}

class _AppointmentList extends StatelessWidget {
  final List<dynamic> appointments;
  const _AppointmentList({required this.appointments});

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('No appointments found',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: appointments.length,
      itemBuilder: (context, idx) {
        final appt = appointments[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              context.push('/doctor/patient-details/${appt.patientId}');
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MockAvatarWidget(
                          name: appt.patientName, size: 44, avatarUrl: appt.patientAvatar),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appt.patientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('EEE, MMM dd').format(appt.date)} • ${appt.timeSlot}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(status: appt.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Tag(
                          icon: appt.type == 'Online'
                              ? Icons.videocam
                              : Icons.person,
                          label: appt.type),
                      const SizedBox(width: 8),
                      if (appt.notes.isNotEmpty)
                        _Tag(
                            icon: Icons.medical_services_outlined,
                            label: appt.notes.length > 25
                                ? '${appt.notes.substring(0, 25)}...'
                                : appt.notes),
                    ],
                  ),
                  if (appt.status == 'Pending') ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Appointment declined')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorRed,
                              side: const BorderSide(
                                  color: AppTheme.errorRed),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Appointment accepted')),
                              );
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
