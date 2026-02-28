import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../mock_data/mock_patients.dart';
import '../../../models/patient_model.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  late List<PatientModel> _patients;
  String _search = '';
  String _genderFilter = 'All';
  String _bloodFilter = 'All';

  static const _bloodGroups = [
    'All', 'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];
  static const _genders = ['All', 'Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _patients = mockPatients.toList();
  }

  List<PatientModel> get _filtered {
    var list = _patients;
    if (_genderFilter != 'All') {
      list = list.where((p) => p.gender == _genderFilter).toList();
    }
    if (_bloodFilter != 'All') {
      list = list.where((p) => p.bloodGroup == _bloodFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.email.toLowerCase().contains(q) ||
              p.phone.toLowerCase().contains(q) ||
              p.bloodGroup.toLowerCase().contains(q))
          .toList();
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  // â”€â”€ View Details â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _viewDetails(PatientModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              // Header
              Row(children: [
                MockAvatarWidget(
                    name: p.name, size: 56, avatarUrl: p.avatarUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('${p.age} yrs â€¢ ${p.gender}',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(p.bloodGroup,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue)),
                ),
              ]),
              const SizedBox(height: 16),
              // Stats chips
              Row(children: [
                _StatChip(
                    icon: Icons.monitor_weight_outlined,
                    label: '${p.weight.toInt()} kg'),
                const SizedBox(width: 8),
                _StatChip(
                    icon: Icons.height,
                    label: '${p.height.toInt()} cm'),
                const SizedBox(width: 8),
                _StatChip(
                    icon: Icons.speed_outlined,
                    label: 'BMI ${p.bmi.toStringAsFixed(1)}'),
              ]),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              _DetailRow(Icons.email_outlined, 'Email', p.email),
              _DetailRow(Icons.phone_outlined, 'Phone', p.phone),
              _DetailRow(Icons.location_on_outlined, 'Address', p.address),
              _DetailRow(Icons.cake_outlined, 'Date of Birth',
                  DateFormat('MMM dd, yyyy').format(p.dateOfBirth)),
              _DetailRow(Icons.contact_phone_outlined, 'Emergency Contact',
                  '${p.emergencyContact} â€” ${p.emergencyPhone}'),
              if (p.allergies.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.warning_amber_outlined,
                      size: 15, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(ctx).style,
                        children: [
                          const TextSpan(
                              text: 'Allergies: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.errorRed)),
                          TextSpan(
                              text: p.allergies.join(', '),
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openForm(existing: p);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('Medical History'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _viewMedicalHistory(p);
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Medical History â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _viewMedicalHistory(PatientModel p) {
    final appts = mockAppointments
        .where((a) => a.patientId == p.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (ctx, ctrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Column(
                children: [
                  Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  Row(children: [
                    const Icon(Icons.history,
                        color: AppTheme.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    Text('${p.name} â€” Medical History',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 6),
                  // Stats row
                  Row(children: [
                    _InfoPill(
                        label: '${appts.length} Visits',
                        color: AppTheme.primaryBlue),
                    const SizedBox(width: 8),
                    _InfoPill(
                        label:
                            '${appts.where((a) => a.status == 'Completed').length} Completed',
                        color: AppTheme.successGreen),
                    const SizedBox(width: 8),
                    _InfoPill(
                        label: 'BMI ${p.bmi.toStringAsFixed(1)}',
                        color: AppTheme.warningAmber),
                  ]),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: appts.isEmpty
                  ? const Center(
                      child: Text('No appointment records found.',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: appts.length,
                      itemBuilder: (ctx, i) {
                        final a = appts[i];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: _statusColor(a.status)
                                .withValues(alpha: 0.1),
                            child: Icon(
                              a.type == 'Online'
                                  ? Icons.videocam_outlined
                                  : Icons.local_hospital_outlined,
                              size: 18,
                              color: _statusColor(a.status),
                            ),
                          ),
                          title: Text(a.doctorName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${a.doctorSpecialty}  â€¢  ${DateFormat('MMM dd, yyyy').format(a.date)}',
                              style: const TextStyle(fontSize: 11)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusColor(a.status)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(a.status,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(a.status))),
                          ),
                        );
                      },
                    ),
            ),
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

  // â”€â”€ Add / Edit Form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _openForm({PatientModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final emailCtrl =
        TextEditingController(text: existing?.email ?? '');
    final phoneCtrl =
        TextEditingController(text: existing?.phone ?? '');
    final addressCtrl =
        TextEditingController(text: existing?.address ?? '');
    final ecNameCtrl =
        TextEditingController(text: existing?.emergencyContact ?? '');
    final ecPhoneCtrl =
        TextEditingController(text: existing?.emergencyPhone ?? '');
    final heightCtrl = TextEditingController(
        text: existing != null ? '${existing.height.toInt()}' : '');
    final weightCtrl = TextEditingController(
        text: existing != null ? '${existing.weight.toInt()}' : '');
    String gender = existing?.gender ?? 'Male';
    String bloodGroup = existing?.bloodGroup ?? 'A+';
    DateTime dob = existing?.dateOfBirth ?? DateTime(1990, 1, 1);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  Text(isEdit ? 'Edit Patient' : 'Add New Patient',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder()),
                        items: ['Male', 'Female', 'Other']
                            .map((g) => DropdownMenuItem(
                                value: g, child: Text(g)))
                            .toList(),
                        onChanged: (v) =>
                            setLocal(() => gender = v ?? gender),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: bloodGroup,
                        decoration: const InputDecoration(
                            labelText: 'Blood Group',
                            border: OutlineInputBorder()),
                        items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                            .map((b) => DropdownMenuItem(
                                value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) =>
                            setLocal(() => bloodGroup = v ?? bloodGroup),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Date of birth
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: dob,
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setLocal(() => dob = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake_outlined),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(DateFormat('MMM dd, yyyy').format(dob)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: Icon(Icons.height),
                            border: OutlineInputBorder()),
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                            border: OutlineInputBorder()),
                        validator: (v) =>
                            double.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ecNameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Emergency Contact Name',
                        prefixIcon: Icon(Icons.contact_phone_outlined),
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ecPhoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Emergency Contact Phone',
                        prefixIcon: Icon(Icons.phone_callback_outlined),
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        final updated = PatientModel(
                          id: existing?.id ??
                              'pat_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          dateOfBirth: dob,
                          gender: gender,
                          bloodGroup: bloodGroup,
                          address: addressCtrl.text.trim(),
                          avatarUrl: existing?.avatarUrl ?? '',
                          allergies: existing?.allergies ?? [],
                          emergencyContact: ecNameCtrl.text.trim(),
                          emergencyPhone: ecPhoneCtrl.text.trim(),
                          height: double.tryParse(heightCtrl.text) ?? 170,
                          weight: double.tryParse(weightCtrl.text) ?? 70,
                        );
                        setState(() {
                          if (isEdit) {
                            final idx = _patients
                                .indexWhere((p) => p.id == existing.id);
                            if (idx != -1) _patients[idx] = updated;
                          } else {
                            _patients.add(updated);
                          }
                        });
                        Navigator.of(ctx).pop();
                        _snack(isEdit
                            ? '${updated.name} updated.'
                            : '${updated.name} added.');
                      },
                      child:
                          Text(isEdit ? 'Save Changes' : 'Add Patient'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // â”€â”€ Delete â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _confirmDelete(PatientModel p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Patient'),
        content: Text(
            'Remove ${p.name} from the system? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white),
            onPressed: () {
              setState(() => _patients.removeWhere((x) => x.id == p.id));
              Navigator.of(ctx).pop();
              _snack('${p.name} removed.');
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Filter sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const Text('Filter Patients',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              const Text('Gender',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _genders
                    .map((g) => ChoiceChip(
                          label: Text(g),
                          selected: _genderFilter == g,
                          selectedColor:
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                          onSelected: (_) => setLocal(() {
                            _genderFilter = g;
                            setState(() {});
                          }),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text('Blood Group',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _bloodGroups
                    .map((b) => ChoiceChip(
                          label: Text(b),
                          selected: _bloodFilter == b,
                          selectedColor:
                              AppTheme.errorRed.withValues(alpha: 0.15),
                          onSelected: (_) => setLocal(() {
                            _bloodFilter = b;
                            setState(() {});
                          }),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _genderFilter = 'All';
                        _bloodFilter = 'All';
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Clear Filters'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Apply'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    final displayed = _filtered;
    final hasActiveFilter = _genderFilter != 'All' || _bloodFilter != 'All';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Patients'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search name, email, phone...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Counts + filter row
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text('${displayed.length} patient${displayed.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                if (hasActiveFilter) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() {
                      _genderFilter = 'All';
                      _bloodFilter = 'All';
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                            [
                              if (_genderFilter != 'All') _genderFilter,
                              if (_bloodFilter != 'All') _bloodFilter,
                            ].join(', '),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.close,
                            size: 12, color: AppTheme.primaryBlue),
                      ]),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: _showFilterSheet,
                  icon: Icon(
                    Icons.filter_list,
                    size: 18,
                    color: hasActiveFilter
                        ? AppTheme.primaryBlue
                        : AppTheme.textSecondary,
                  ),
                  label: Text(
                    'Filter',
                    style: TextStyle(
                        color: hasActiveFilter
                            ? AppTheme.primaryBlue
                            : AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Patient list
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search_outlined,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No patients found',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: displayed.length,
                    itemBuilder: (ctx, idx) {
                      final p = displayed[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _viewDetails(p),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                MockAvatarWidget(
                                    name: p.name,
                                    size: 48,
                                    avatarUrl: p.avatarUrl),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${p.age} yrs â€¢ ${p.gender}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary),
                                      ),
                                      Text(p.phone,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(p.bloodGroup,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.primaryBlue)),
                                    ),
                                    if (p.allergies.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.errorRed
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '${p.allergies.length} allerg.',
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.errorRed),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'view',
                                        child: Row(children: [
                                          Icon(Icons.visibility_outlined,
                                              size: 16),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ])),
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(children: [
                                          Icon(Icons.edit_outlined,
                                              size: 16),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ])),
                                    const PopupMenuItem(
                                        value: 'history',
                                        child: Row(children: [
                                          Icon(Icons.history, size: 16),
                                          SizedBox(width: 8),
                                          Text('Medical History'),
                                        ])),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(children: [
                                          Icon(Icons.delete_outline,
                                              size: 16,
                                              color: AppTheme.errorRed),
                                          SizedBox(width: 8),
                                          Text('Remove',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.errorRed)),
                                        ])),
                                  ],
                                  onSelected: (v) {
                                    switch (v) {
                                      case 'view':
                                        _viewDetails(p);
                                        break;
                                      case 'edit':
                                        _openForm(existing: p);
                                        break;
                                      case 'history':
                                        _viewMedicalHistory(p);
                                        break;
                                      case 'delete':
                                        _confirmDelete(p);
                                        break;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Add Patient'),
      ),
    );
  }
}

// â”€â”€ Helper widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: AppTheme.primaryBlue),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue)),
      ]),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}

