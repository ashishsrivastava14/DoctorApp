import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_doctors.dart';
import '../../../models/doctor_model.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  late List<DoctorModel> _doctors;
  String _search = '';
  String _specialtyFilter = 'All';

  @override
  void initState() {
    super.initState();
    _doctors = mockDoctors.toList();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  List<DoctorModel> get _filtered {
    var list = _doctors;
    if (_search.isNotEmpty) {
      list = list
          .where((d) =>
              d.name.toLowerCase().contains(_search.toLowerCase()) ||
              d.specialty.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (_specialtyFilter != 'All') {
      list = list.where((d) => d.specialty == _specialtyFilter).toList();
    }
    return list;
  }

  List<String> get _specialties =>
      ['All', ...{..._doctors.map((d) => d.specialty)}];

  // ── View Profile ──────────────────────────────────────────────────────────

  void _viewProfile(DoctorModel doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
            Row(
              children: [
                MockAvatarWidget(
                    name: doc.name, size: 72, avatarUrl: doc.avatarUrl),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(doc.specialty,
                          style: const TextStyle(
                              color: AppTheme.primaryBlue, fontSize: 13)),
                      Text(doc.hospitalName,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: doc.isAvailable
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.errorRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    doc.isAvailable ? 'Active' : 'Inactive',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: doc.isAvailable
                            ? AppTheme.successGreen
                            : AppTheme.errorRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats row
            Row(
              children: [
                _ViewStatChip(
                    icon: Icons.star,
                    color: Colors.amber,
                    value: doc.rating.toStringAsFixed(1),
                    label: 'Rating'),
                const SizedBox(width: 8),
                _ViewStatChip(
                    icon: Icons.people,
                    color: AppTheme.primaryBlue,
                    value: '${doc.patientCount}',
                    label: 'Patients'),
                const SizedBox(width: 8),
                _ViewStatChip(
                    icon: Icons.workspace_premium,
                    color: Colors.purple,
                    value: '${doc.experienceYears} yr',
                    label: 'Exp.'),
                const SizedBox(width: 8),
                _ViewStatChip(
                    icon: Icons.attach_money,
                    color: AppTheme.successGreen,
                    value: '\$${doc.consultationFee.toInt()}',
                    label: 'Fee'),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _DetailRow(Icons.email_outlined, 'Email', doc.email),
            _DetailRow(Icons.phone_outlined, 'Phone', doc.phone),
            _DetailRow(Icons.school_outlined, 'Education', doc.education),
            _DetailRow(Icons.location_on_outlined, 'Address', doc.address),
            const SizedBox(height: 12),
            Text('About',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Text(doc.bio,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            Text('Available Days',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: doc.availableDays
                  .map((d) => Chip(
                        label: Text(d,
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor:
                            AppTheme.primaryBlue.withValues(alpha: 0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Add / Edit Doctor ─────────────────────────────────────────────────────

  void _openForm({DoctorModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final emailCtrl =
        TextEditingController(text: existing?.email ?? '');
    final phoneCtrl =
        TextEditingController(text: existing?.phone ?? '');
    final bioCtrl = TextEditingController(text: existing?.bio ?? '');
    final educationCtrl =
        TextEditingController(text: existing?.education ?? '');
    final hospitalCtrl =
        TextEditingController(text: existing?.hospitalName ?? '');
    final addressCtrl =
        TextEditingController(text: existing?.address ?? '');
    final feeCtrl = TextEditingController(
        text: existing?.consultationFee.toInt().toString() ?? '');
    final expCtrl = TextEditingController(
        text: existing?.experienceYears.toString() ?? '');
    String specialty =
        existing?.specialty ?? AppConstants.specialties.first;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              builder: (_, ctrl) => Form(
                key: formKey,
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                    Text(isEdit ? 'Edit Doctor' : 'Add New Doctor',
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    _FormField(
                        ctrl: nameCtrl,
                        label: 'Full Name',
                        icon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || !v.contains('@')
                                ? 'Valid email required'
                                : null),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: phoneCtrl,
                        label: 'Phone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: specialty,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        prefixIcon:
                            Icon(Icons.medical_services_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.specialties
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setLocal(() => specialty = v ?? specialty),
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: educationCtrl,
                        label: 'Education',
                        icon: Icons.school_outlined,
                        validator: (v) =>
                            v == null || v.trim().isEmpty
                                ? 'Required'
                                : null),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: hospitalCtrl,
                        label: 'Hospital Name',
                        icon: Icons.local_hospital_outlined),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: addressCtrl,
                        label: 'Address',
                        icon: Icons.location_on_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _FormField(
                              ctrl: feeCtrl,
                              label: 'Fee (\$)',
                              icon: Icons.attach_money,
                              keyboardType: TextInputType.number),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FormField(
                              ctrl: expCtrl,
                              label: 'Experience (yrs)',
                              icon: Icons.workspace_premium_outlined,
                              keyboardType: TextInputType.number),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                        ctrl: bioCtrl,
                        label: 'Bio',
                        icon: Icons.info_outline,
                        maxLines: 3),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ??
                            false)) {
                          return;
                        }
                        final updated = DoctorModel(
                          id: existing?.id ??
                              'doc_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          specialty: specialty,
                          bio: bioCtrl.text.trim(),
                          education: educationCtrl.text.trim(),
                          experienceYears:
                              int.tryParse(expCtrl.text) ?? 0,
                          rating: existing?.rating ?? 0.0,
                          reviewCount: existing?.reviewCount ?? 0,
                          patientCount: existing?.patientCount ?? 0,
                          consultationFee:
                              double.tryParse(feeCtrl.text) ?? 0,
                          avatarUrl: existing?.avatarUrl ?? '',
                          isAvailable: existing?.isAvailable ?? true,
                          availableDays: existing?.availableDays ??
                              const [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri'
                              ],
                          availableSlots:
                              existing?.availableSlots ?? const [],
                          hospitalName: hospitalCtrl.text.trim(),
                          address: addressCtrl.text.trim(),
                        );
                        setState(() {
                          if (isEdit) {
                            final i = _doctors.indexWhere(
                                (d) => d.id == existing.id);
                            if (i != -1) _doctors[i] = updated;
                          } else {
                            _doctors.add(updated);
                          }
                        });
                        Navigator.of(ctx).pop();
                        _snack(isEdit
                            ? '${updated.name} updated.'
                            : '${updated.name} added.');
                      },
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      child: Text(isEdit ? 'Save Changes' : 'Add Doctor'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Toggle active/inactive ────────────────────────────────────────────────

  void _toggleStatus(DoctorModel doc) {
    final idx = _doctors.indexWhere((d) => d.id == doc.id);
    if (idx == -1) return;
    setState(() {
      _doctors[idx] = _doctors[idx].copyWith(
          isAvailable: !_doctors[idx].isAvailable);
    });
    final status = _doctors[idx].isAvailable ? 'Active' : 'Inactive';
    _snack('${doc.name} marked as $status.');
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  void _confirmDelete(DoctorModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Doctor'),
        content: Text(
            'Are you sure you want to remove ${doc.name}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white),
            onPressed: () {
              setState(
                  () => _doctors.removeWhere((d) => d.id == doc.id));
              Navigator.of(ctx).pop();
              _snack('${doc.name} removed.');
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty...',
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
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _specialties.length,
              itemBuilder: (_, idx) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_specialties[idx],
                      style: const TextStyle(fontSize: 12)),
                  selected: _specialtyFilter == _specialties[idx],
                  selectedColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                  onSelected: (_) => setState(
                      () => _specialtyFilter = _specialties[idx]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${displayed.length} doctor${displayed.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No doctors found',
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
                      final doc = displayed[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              MockAvatarWidget(
                                  name: doc.name,
                                  size: 48,
                                  avatarUrl: doc.avatarUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(doc.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    Text(doc.specialty,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.primaryBlue)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${doc.experienceYears} yrs • ${doc.patientCount} patients',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 14),
                                      Text(' ${doc.rating}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: doc.isAvailable
                                          ? AppTheme.successGreen
                                              .withValues(alpha: 0.1)
                                          : AppTheme.errorRed
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      doc.isAvailable
                                          ? 'Active'
                                          : 'Inactive',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: doc.isAvailable
                                            ? AppTheme.successGreen
                                            : AppTheme.errorRed,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              PopupMenuButton<String>(
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                      value: 'view',
                                      child: Row(children: [
                                        Icon(Icons.visibility_outlined,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text('View Profile'),
                                      ])),
                                  const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(children: [
                                        Icon(Icons.edit_outlined,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ])),
                                  PopupMenuItem(
                                      value: 'toggle',
                                      child: Row(children: [
                                        Icon(
                                            doc.isAvailable
                                                ? Icons
                                                    .toggle_off_outlined
                                                : Icons
                                                    .toggle_on_outlined,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Text(doc.isAvailable
                                            ? 'Set Inactive'
                                            : 'Set Active'),
                                      ])),
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(children: [
                                        Icon(Icons.delete_outline,
                                            size: 18,
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
                                      _viewProfile(doc);
                                      break;
                                    case 'edit':
                                      _openForm(existing: doc);
                                      break;
                                    case 'toggle':
                                      _toggleStatus(doc);
                                      break;
                                    case 'delete':
                                      _confirmDelete(doc);
                                      break;
                                  }
                                },
                              ),
                            ],
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
        icon: const Icon(Icons.person_add),
        label: const Text('Add Doctor'),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ViewStatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _ViewStatChip(
      {required this.icon,
      required this.color,
      required this.value,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
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

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
