import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../../mock_data/mock_patients.dart';
import '../../../mock_data/mock_appointments.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() =>
      _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  String _searchQuery = '';
  String _filterGender = 'All';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    // Get patients who have appointments with this doctor
    final doctorPatientIds = mockAppointments
        .where(
            (a) => a.doctorId == auth.userId || a.doctorId == 'doc_1')
        .map((a) => a.patientId)
        .toSet();

    var patients = mockPatients
        .where((p) => doctorPatientIds.contains(p.id))
        .toList();

    if (_searchQuery.isNotEmpty) {
      patients = patients
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    if (_filterGender != 'All') {
      patients = patients
          .where((p) => p.gender == _filterGender)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Patients')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search patients...',
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
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('${patients.length} patients',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const Spacer(),
                ...['All', 'Male', 'Female'].map((g) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(g, style: const TextStyle(fontSize: 12)),
                        selected: _filterGender == g,
                        selectedColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.15),
                        onSelected: (_) =>
                            setState(() => _filterGender = g),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Patient List
          Expanded(
            child: patients.isEmpty
                ? const Center(
                    child: Text('No patients found',
                        style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: patients.length,
                    itemBuilder: (ctx, idx) {
                      final patient = patients[idx];
                      final lastAppt = mockAppointments
                          .where((a) => a.patientId == patient.id)
                          .toList()
                        ..sort((a, b) =>
                            b.date.compareTo(a.date));
                      final apptCount = lastAppt.length;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: MockAvatarWidget(
                              name: patient.name, size: 44, avatarUrl: patient.avatarUrl),
                          title: Text(patient.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${patient.age}y • ${patient.gender} • ${patient.bloodGroup}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary),
                              ),
                              Text(
                                '$apptCount visits',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.primaryBlue),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.grey),
                          onTap: () {
                            context.push(
                                '/doctor/patient-details/${patient.id}');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
