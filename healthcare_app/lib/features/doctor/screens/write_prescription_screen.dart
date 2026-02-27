import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_patients.dart';

class WritePrescriptionScreen extends StatefulWidget {
  final String? patientId;
  const WritePrescriptionScreen({super.key, this.patientId});

  @override
  State<WritePrescriptionScreen> createState() =>
      _WritePrescriptionScreenState();
}

class _WritePrescriptionScreenState extends State<WritePrescriptionScreen> {
  String? _selectedPatientId;
  final _diagnosisCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _followUpDate = DateTime.now().add(const Duration(days: 14));
  final List<_MedicineEntry> _medicines = [_MedicineEntry()];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId ?? mockPatients.first.id;
  }

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _notesCtrl.dispose();
    for (final m in _medicines) {
      m.dispose();
    }
    super.dispose();
  }

  void _addMedicine() {
    setState(() => _medicines.add(_MedicineEntry()));
  }

  void _removeMedicine(int idx) {
    if (_medicines.length > 1) {
      setState(() {
        _medicines[idx].dispose();
        _medicines.removeAt(idx);
      });
    }
  }

  void _submitPrescription() {
    if (_diagnosisCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a diagnosis')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            color: AppTheme.successGreen, size: 48),
        title: const Text('Prescription Created'),
        content: const Text(
            'The prescription has been saved and sent to the patient.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              context.pop();         // navigate back
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Prescription'),
        actions: [
          TextButton(
            onPressed: _submitPrescription,
            child: const Text('Submit',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patient',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPatientId,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Select Patient',
                      ),
                      items: mockPatients
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedPatientId = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Diagnosis
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnosis',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _diagnosisCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter diagnosis',
                        prefixIcon: Icon(Icons.medical_information_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Medicines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Medicines',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        TextButton.icon(
                          onPressed: _addMedicine,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._medicines.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final med = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Medicine ${idx + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13)),
                                const Spacer(),
                                if (_medicines.length > 1)
                                  IconButton(
                                    onPressed: () =>
                                        _removeMedicine(idx),
                                    icon: const Icon(Icons.remove_circle,
                                        color: AppTheme.errorRed,
                                        size: 20),
                                  ),
                              ],
                            ),
                            TextFormField(
                              controller: med.nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Medicine Name',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: med.dosageCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Dosage',
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: med.frequency,
                                    decoration: const InputDecoration(
                                      labelText: 'Frequency',
                                      isDense: true,
                                    ),
                                    items: [
                                      'Once daily',
                                      'Twice daily',
                                      'Three times daily',
                                      'Every 8 hours',
                                      'As needed',
                                    ]
                                        .map((f) => DropdownMenuItem(
                                            value: f,
                                            child: Text(f,
                                                style: const TextStyle(
                                                    fontSize: 12))))
                                        .toList(),
                                    onChanged: (v) => setState(
                                        () => med.frequency = v!),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: med.durationCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Duration (e.g. 7 days)',
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Follow-up & Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Follow-up & Notes',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.calendar_today,
                          color: AppTheme.primaryBlue),
                      title: const Text('Follow-up Date'),
                      subtitle: Text(
                          DateFormat('MMM dd, yyyy')
                              .format(_followUpDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _followUpDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => _followUpDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Additional notes...',
                        prefixIcon: Icon(Icons.notes),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitPrescription,
                icon: const Icon(Icons.send),
                label: const Text('Submit Prescription'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _MedicineEntry {
  final nameCtrl = TextEditingController();
  final dosageCtrl = TextEditingController(text: '500mg');
  final durationCtrl = TextEditingController(text: '7 days');
  String frequency = 'Twice daily';

  void dispose() {
    nameCtrl.dispose();
    dosageCtrl.dispose();
    durationCtrl.dispose();
  }
}
