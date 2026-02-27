import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../mock_data/mock_appointments.dart';

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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<dynamic> _filter(String status) {
    var appts = mockAppointments.toList();
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

  Widget _buildList(List<dynamic> appts) {
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MockAvatarWidget(
                        name: a.patientName, size: 40),
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
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13, color: AppTheme.textSecondary),
                    Text(
                      ' ${DateFormat('MMM dd, yyyy').format(a.date)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time,
                        size: 13, color: AppTheme.textSecondary),
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
        );
      },
    );
  }
}
