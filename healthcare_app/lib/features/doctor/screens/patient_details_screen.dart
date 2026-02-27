import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../mock_data/mock_patients.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../mock_data/mock_prescriptions.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient = mockPatients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => mockPatients.first,
    );

    final patientAppts = mockAppointments
        .where((a) => a.patientId == patient.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final patientPrescs = mockPrescriptions
        .where((p) => p.patientId == patient.id)
        .toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Details'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Appointments'),
              Tab(text: 'Prescriptions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Patient Profile Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          MockAvatarWidget(
                              name: patient.name, size: 70),
                          const SizedBox(height: 12),
                          Text(patient.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(patient.email,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(patient.phone,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary)),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _InfoCol(
                                  label: 'Age',
                                  value: '${patient.age}'),
                              _InfoCol(
                                  label: 'Gender',
                                  value: patient.gender),
                              _InfoCol(
                                  label: 'Blood',
                                  value: patient.bloodGroup),
                              _InfoCol(
                                  label: 'BMI',
                                  value:
                                      patient.bmi.toStringAsFixed(1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Medical History
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Medical History',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          _DetailRow(
                              label: 'Conditions',
                              value: patient.allergies.isEmpty
                                  ? 'None'
                                  : patient.allergies.join(', ')),
                          _DetailRow(
                              label: 'Allergies',
                              value: patient.allergies.isEmpty
                                  ? 'None'
                                  : patient.allergies.join(', ')),
                          _DetailRow(
                              label: 'Emergency Contact',
                              value: patient.emergencyContact),
                          _DetailRow(
                              label: 'Emergency Phone',
                              value: patient.emergencyPhone),
                          _DetailRow(
                              label: 'Address',
                              value: patient.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Vitals
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latest Vitals',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _VitalCard(
                                  icon: Icons.favorite,
                                  label: 'BP',
                                  value: '120/80',
                                  color: AppTheme.errorRed),
                              const SizedBox(width: 8),
                              _VitalCard(
                                  icon: Icons.water_drop,
                                  label: 'Sugar',
                                  value: '98 mg/dL',
                                  color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              _VitalCard(
                                  icon: Icons.thermostat,
                                  label: 'Temp',
                                  value: '98.6°F',
                                  color: Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Appointments Tab
            patientAppts.isEmpty
                ? const Center(child: Text('No appointments'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: patientAppts.length,
                    itemBuilder: (ctx, idx) {
                      final appt = patientAppts[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                            child: Text(
                              DateFormat('dd').format(appt.date),
                              style: const TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          title: Text(
                            DateFormat('EEEE, MMM dd yyyy')
                                .format(appt.date),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${appt.timeSlot} • ${appt.type}',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                          trailing:
                              StatusChip(status: appt.status),
                        ),
                      );
                    },
                  ),

            // Prescriptions Tab
            patientPrescs.isEmpty
                ? const Center(child: Text('No prescriptions'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: patientPrescs.length,
                    itemBuilder: (ctx, idx) {
                      final presc = patientPrescs[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.successGreen
                                .withValues(alpha: 0.1),
                            child: const Icon(Icons.medication,
                                color: AppTheme.successGreen, size: 20),
                          ),
                          title: Text('Rx #${presc.id}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          subtitle: Text(
                            DateFormat('MMM dd, yyyy')
                                .format(presc.date),
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('Diagnosis: ${presc.diagnosis}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  ...presc.medicines.map((m) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle,
                                                size: 6,
                                                color:
                                                    AppTheme.primaryBlue),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${m.name} - ${m.dosage} (${m.frequency}) for ${m.duration}',
                                                style: const TextStyle(
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  if (presc.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Notes: ${presc.notes}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                AppTheme.textSecondary)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _VitalCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
