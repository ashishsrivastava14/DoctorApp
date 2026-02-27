import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../mock_data/mock_prescriptions.dart';
import '../../../features/auth/auth_notifier.dart';

class MedicalRecordsScreen extends ConsumerWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final prescriptions = mockPrescriptions
        .where((p) => p.patientId == auth.userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medical Records'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Prescriptions'),
              Tab(text: 'Lab Reports'),
              Tab(text: 'Imaging'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document upload (mock)')),
            );
          },
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload'),
        ),
        body: TabBarView(
          children: [
            // Prescriptions Tab
            prescriptions.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.description_outlined,
                    title: 'No Prescriptions',
                    message: 'Your prescriptions will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      final p = prescriptions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.description,
                                color: AppTheme.primaryBlue),
                          ),
                          title: Text(p.diagnosis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15)),
                          subtitle: Text(
                            '${p.doctorName} • ${DateFormat('MMM dd, yyyy').format(p.date)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const Text('Medicines:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  ...p.medicines.map((m) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.backgroundLight,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(m.name,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            Text(
                                              '${m.dosage} • ${m.frequency} • ${m.duration}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.textSecondary,
                                              ),
                                            ),
                                            if (m.instructions.isNotEmpty)
                                              Text(
                                                '💊 ${m.instructions}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.primaryBlue,
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                                  if (p.notes.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Notes: ${p.notes}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        )),
                                  ],
                                  if (p.followUpDate != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningAmber
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.event,
                                              color: AppTheme.warningAmber,
                                              size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Follow-up: ${DateFormat('MMM dd, yyyy').format(p.followUpDate!)}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.warningAmber,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            // Lab Reports Tab
            const EmptyStateWidget(
              icon: Icons.science_outlined,
              title: 'Lab Reports',
              message: 'Your lab reports will appear here once available.',
            ),
            // Imaging Tab
            const EmptyStateWidget(
              icon: Icons.image_outlined,
              title: 'Imaging',
              message: 'Your imaging reports (X-Ray, MRI, CT) appear here.',
            ),
          ],
        ),
      ),
    );
  }
}
