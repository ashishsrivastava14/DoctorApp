import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../models/appointment_model.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() =>
      _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState
    extends State<AdminAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late List<AppointmentModel> _appointments;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
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
        _appointments[idx] =
            _appointments[idx].copyWith(status: newStatus);
      }
    });
  }

  List<AppointmentModel> _filter(String status) {
    var appts = _appointments;
    if (status != 'All') {
      appts = appts.where((a) => a.status == status).toList();
    }
    if (_searchQuery.isNotEmpty) {
      appts = appts
          .where((a) =>
              a.patientName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              a.doctorName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return appts..sort((a, b) => b.date.compareTo(a.date));
  }

  void _viewDetails(AppointmentModel a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.45,
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
            Row(
              children: [
                MockAvatarWidget(
                    name: a.patientName,
                    size: 52,
                    avatarUrl: a.patientAvatar),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.patientName,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      StatusChip(status: a.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            _AdminDRow(
                icon: Icons.person_outline,
                label: 'Doctor',
                value: a.doctorName),
            _AdminDRow(
                icon: Icons.medical_services_outlined,
                label: 'Specialty',
                value: a.doctorSpecialty),
            _AdminDRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateFormat('EEEE, MMM dd, yyyy')
                    .format(a.date)),
            _AdminDRow(
                icon: Icons.access_time,
                label: 'Time',
                value: a.timeSlot),
            _AdminDRow(
                icon:
                    a.type == 'Online' ? Icons.videocam : Icons.person,
                label: 'Type',
                value: a.type),
            _AdminDRow(
                icon: Icons.monetization_on,
                label: 'Fee',
                value: '\$${a.fee.toStringAsFixed(0)}'),
            if (a.notes.isNotEmpty)
              _AdminDRow(
                  icon: Icons.notes, label: 'Notes', value: a.notes),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Change Status',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (a.status != 'Confirmed')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _updateStatus(a.id, 'Confirmed');
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Appointment confirmed')));
                    },
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white)),
                  ),
                if (a.status != 'Completed')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _updateStatus(a.id, 'Completed');
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Appointment marked complete')));
                    },
                    child: const Text('Complete',
                        style: TextStyle(color: Colors.white)),
                  ),
                if (a.status != 'Cancelled')
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorRed,
                        side: const BorderSide(
                            color: AppTheme.errorRed),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8)),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _updateStatus(a.id, 'Cancelled');
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Appointment cancelled')));
                    },
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Appointments'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by patient or doctor...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildList(_filter('All')),
                _buildList(_filter('Pending')),
                _buildList(_filter('Confirmed')),
                _buildList(_filter('Completed')),
                _buildList(_filter('Cancelled')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AppointmentModel> appts) {
    if (appts.isEmpty) {
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: appts.length,
      itemBuilder: (ctx, idx) {
        final a = appts[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _viewDetails(a),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MockAvatarWidget(
                          name: a.patientName,
                          size: 40,
                          avatarUrl: a.patientAvatar),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(a.patientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            Text(
                              'with ${a.doctorName}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(status: a.status),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (v) {
                          if (v == 'details') {
                            _viewDetails(a);
                          } else {
                            _updateStatus(a.id, v);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text(
                                        'Status changed to $v')));
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'details',
                              child: Text('View Details')),
                          if (a.status != 'Confirmed')
                            const PopupMenuItem(
                                value: 'Confirmed',
                                child: Text('Confirm')),
                          if (a.status != 'Completed')
                            const PopupMenuItem(
                                value: 'Completed',
                                child: Text('Mark Complete')),
                          if (a.status != 'Cancelled')
                            PopupMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: AppTheme.errorRed)),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 13,
                          color: AppTheme.textSecondary),
                      Text(
                        ' ${DateFormat('MMM dd, yyyy').format(a.date)}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time,
                          size: 13,
                          color: AppTheme.textSecondary),
                      Text(' ${a.timeSlot}',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      Icon(
                          a.type == 'Online'
                              ? Icons.videocam
                              : Icons.person,
                          size: 13,
                          color: AppTheme.textSecondary),
                      Text(' ${a.type}',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _AdminDRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AdminDRow(
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
