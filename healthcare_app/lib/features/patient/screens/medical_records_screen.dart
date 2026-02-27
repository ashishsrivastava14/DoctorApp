import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../mock_data/mock_prescriptions.dart';
import '../../../features/auth/auth_notifier.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  final List<_UploadedRecord> _uploadedRecords = [];

  static const _docTypes = [
    _DocType(icon: Icons.picture_as_pdf, label: 'PDF Report', color: Color(0xFFE53935), ext: '.pdf'),
    _DocType(icon: Icons.image_outlined, label: 'Image (JPG/PNG)', color: Color(0xFF1E88E5), ext: '.jpg'),
    _DocType(icon: Icons.description_outlined, label: 'Word Document', color: Color(0xFF1565C0), ext: '.docx'),
    _DocType(icon: Icons.table_chart_outlined, label: 'Spreadsheet', color: Color(0xFF2E7D32), ext: '.xlsx'),
  ];

  static const _categories = ['Lab Report', 'Imaging', 'Prescription', 'Other'];

  void _showUploadSheet() {
    String? selectedCategory;
    _DocType? selectedDocType;
    bool isUploading = false;
    double progress = 0;
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Upload Medical Record',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Record name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Record Name',
                    hintText: 'e.g. Blood Test Results',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                // Category selector
                const Text('Category',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _categories
                      .map((c) => ChoiceChip(
                            label: Text(c,
                                style: const TextStyle(fontSize: 12)),
                            selected: selectedCategory == c,
                            selectedColor:
                                AppTheme.primaryBlue.withValues(alpha: 0.15),
                            onSelected: (_) =>
                                setSheetState(() => selectedCategory = c),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // File type selector
                const Text('File Type',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.5,
                  children: _docTypes
                      .map((dt) => GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedDocType = dt),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedDocType == dt
                                    ? dt.color.withValues(alpha: 0.12)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedDocType == dt
                                      ? dt.color
                                      : Colors.grey.shade300,
                                  width: selectedDocType == dt ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(dt.icon, color: dt.color, size: 18),
                                  const SizedBox(width: 6),
                                  Text(dt.label,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: dt.color,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                if (isUploading) ...[
                  Row(
                    children: [
                      const Icon(Icons.upload, color: AppTheme.primaryBlue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryBlue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (isUploading ||
                            selectedDocType == null ||
                            selectedCategory == null)
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter a record name')),
                              );
                              return;
                            }
                            setSheetState(() => isUploading = true);
                            // Simulate upload progress
                            for (int i = 1; i <= 10; i++) {
                              await Future.delayed(
                                  const Duration(milliseconds: 120));
                              setSheetState(() => progress = i / 10);
                            }
                            final record = _UploadedRecord(
                              name: nameController.text.trim(),
                              category: selectedCategory!,
                              fileType: selectedDocType!,
                              uploadedAt: DateTime.now(),
                            );
                            if (mounted) {
                              Navigator.pop(sheetCtx);
                              setState(() => _uploadedRecords.add(record));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '"${record.name}" uploaded successfully!'),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.upload_file),
                    label: Text(isUploading ? 'Uploading...' : 'Upload Record'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final prescriptions = mockPrescriptions
        .where((p) => p.patientId == auth.userId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final labReports =
        _uploadedRecords.where((r) => r.category == 'Lab Report').toList();
    final imagingRecords =
        _uploadedRecords.where((r) => r.category == 'Imaging').toList();

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
          onPressed: _showUploadSheet,
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
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.medication_rounded,
                                                      size: 14,
                                                      color: AppTheme.primaryBlue),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      m.instructions,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppTheme.primaryBlue,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
            labReports.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.science_outlined,
                    title: 'Lab Reports',
                    message: 'Tap Upload to add your lab reports.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: labReports.length,
                    itemBuilder: (context, i) =>
                        _UploadedRecordCard(record: labReports[i]),
                  ),
            // Imaging Tab
            imagingRecords.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.image_outlined,
                    title: 'Imaging',
                    message: 'Tap Upload to add X-Ray, MRI or CT scans.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: imagingRecords.length,
                    itemBuilder: (context, i) =>
                        _UploadedRecordCard(record: imagingRecords[i]),
                  ),
          ],
        ),
      ),
    );
  }
}

class _UploadedRecord {
  final String name;
  final String category;
  final _DocType fileType;
  final DateTime uploadedAt;
  const _UploadedRecord({
    required this.name,
    required this.category,
    required this.fileType,
    required this.uploadedAt,
  });
}

class _DocType {
  final IconData icon;
  final String label;
  final Color color;
  final String ext;
  const _DocType(
      {required this.icon,
      required this.label,
      required this.color,
      required this.ext});
}

class _UploadedRecordCard extends StatelessWidget {
  final _UploadedRecord record;
  const _UploadedRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: record.fileType.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(record.fileType.icon,
              color: record.fileType.color, size: 22),
        ),
        title: Text(record.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${record.category} • ${DateFormat('MMM dd, yyyy').format(record.uploadedAt)}',
          style:
              TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.fileType.ext,
                style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
