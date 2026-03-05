import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../models/appointment_model.dart';

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
  late List<AppointmentModel> _appointments;
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _appointments = mockAppointments.toList();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _updateStatus(String id, String newStatus) {
    setState(() {
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _appointments[idx] = _appointments[idx].copyWith(status: newStatus);
      }
    });
  }

  void _addNotesDialog(AppointmentModel appt) {
    final ctrl = TextEditingController(text: appt.notes);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Consultation Notes'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add notes about this appointment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                final idx =
                    _appointments.indexWhere((a) => a.id == appt.id);
                if (idx != -1) {
                  _appointments[idx] =
                      _appointments[idx].copyWith(notes: ctrl.text.trim());
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notes saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(BuildContext context, AppointmentModel appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
            Row(children: [
              MockAvatarWidget(
                  name: appt.patientName,
                  size: 52,
                  avatarUrl: appt.patientAvatar),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.patientName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    StatusChip(status: appt.status),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _DRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormat('EEEE, MMM dd, yyyy').format(appt.date)),
            _DRow(
                icon: Icons.access_time,
                label: 'Time',
                value: appt.timeSlot),
            _DRow(
                icon: appt.type == 'Online'
                    ? Icons.videocam
                    : Icons.local_hospital,
                label: 'Type',
                value: appt.type),
            _DRow(
                icon: Icons.monetization_on,
                label: 'Fee',
                value: '\$${appt.fee.toStringAsFixed(0)}'),
            if (appt.notes.isNotEmpty)
              _DRow(
                  icon: Icons.notes, label: 'Notes', value: appt.notes),
            const SizedBox(height: 16),
            if (appt.status == 'Pending') ...[  
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _updateStatus(appt.id, 'Cancelled');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Appointment declined')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side:
                            const BorderSide(color: AppTheme.errorRed)),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _updateStatus(appt.id, 'Confirmed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Appointment accepted')),
                      );
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ]),
            ],
            if (appt.status == 'Confirmed') ...[  
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, size: 16),
                label: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _updateStatus(appt.id, 'Completed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Appointment marked complete')),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.note_add, size: 16),
                label: const Text('Add Notes'),
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  _addNotesDialog(appt);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final doctorAppts = _appointments
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
                    appointments: _applyFilter(doctorAppts, 'all'),
                    onViewDetails: _viewDetails,
                    onStatusChange: _updateStatus,
                    onAddNotes: _addNotesDialog),
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'Pending'),
                    onViewDetails: _viewDetails,
                    onStatusChange: _updateStatus,
                    onAddNotes: _addNotesDialog),
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'Confirmed'),
                    onViewDetails: _viewDetails,
                    onStatusChange: _updateStatus,
                    onAddNotes: _addNotesDialog),
                _AppointmentList(
                    appointments: _applyFilter(doctorAppts, 'Completed'),
                    onViewDetails: _viewDetails,
                    onStatusChange: _updateStatus,
                    onAddNotes: _addNotesDialog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<AppointmentModel> _applyFilter(List<AppointmentModel> appts, String status) {
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
  final List<AppointmentModel> appointments;
  final void Function(BuildContext, AppointmentModel) onViewDetails;
  final void Function(String id, String status) onStatusChange;
  final void Function(AppointmentModel) onAddNotes;

  const _AppointmentList({
    required this.appointments,
    required this.onViewDetails,
    required this.onStatusChange,
    required this.onAddNotes,
  });

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
            onTap: () => onViewDetails(context, appt),
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
                              onStatusChange(appt.id, 'Cancelled');
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
                              onStatusChange(appt.id, 'Confirmed');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Appointment accepted')),
                              );
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (appt.status == 'Confirmed') ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.note_add, size: 14),
                            label: const Text('Add Notes'),
                            onPressed: () => onAddNotes(appt),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle, size: 14),
                            label: const Text('Complete'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successGreen),
                            onPressed: () {
                              onStatusChange(appt.id, 'Completed');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Marked as completed')),
                              );
                            },
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

class _DRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppTheme.primaryBlue),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
