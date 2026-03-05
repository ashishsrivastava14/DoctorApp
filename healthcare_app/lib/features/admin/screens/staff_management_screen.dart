import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_staff.dart';
import '../../../models/staff_model.dart';

// ── Role & Department constants ───────────────────────────────────────────────
const _kRoles = [
  'Nurse',
  'Receptionist',
  'Lab Technician',
  'Pharmacist',
  'Technician',
  'Administrator',
];

const _kDepartments = [
  'Cardiology',
  'Dermatology',
  'Emergency',
  'General Medicine',
  'Neurology',
  'Orthopedics',
  'Pediatrics',
  'Radiology',
];

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late List<StaffModel> _staff;
  String _roleFilter = 'All';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _staff = mockStaff.toList();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  List<String> get _roles =>
      ['All', ...{..._staff.map((s) => s.role)}];

  List<StaffModel> get _filtered {
    var list = _staff;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.role.toLowerCase().contains(q) ||
              s.department.toLowerCase().contains(q) ||
              s.email.toLowerCase().contains(q))
          .toList();
    }
    if (_roleFilter != 'All') {
      list = list.where((s) => s.role == _roleFilter).toList();
    }
    return list;
  }

  // ── Toggle active status ──────────────────────────────────────────────────

  void _toggleStatus(StaffModel s) {
    final idx = _staff.indexWhere((e) => e.id == s.id);
    if (idx == -1) return;
    setState(() {
      _staff[idx] = _staff[idx].copyWith(isActive: !_staff[idx].isActive);
    });
    _snack('${s.name} marked as ${!s.isActive ? "Active" : "On Leave"}.');
  }

  // ── Delete with confirmation ──────────────────────────────────────────────

  void _confirmDelete(StaffModel s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text(
            'Are you sure you want to remove ${s.name}?\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorRed),
            onPressed: () {
              setState(() => _staff.removeWhere((e) => e.id == s.id));
              Navigator.of(ctx).pop();
              _snack('${s.name} removed.');
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ── View Profile ──────────────────────────────────────────────────────────

  void _viewProfile(StaffModel s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            // drag handle
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
                MockAvatarWidget(name: s.name, size: 68),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(s.role,
                          style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 13)),
                      Text(s.department,
                          style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _toggleStatus(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: s.isActive
                          ? AppTheme.successGreen.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      s.isActive ? 'Active' : 'On Leave',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: s.isActive
                              ? AppTheme.successGreen
                              : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _DetailRow(Icons.email_outlined, 'Email', s.email),
            _DetailRow(Icons.phone_outlined, 'Phone', s.phone),
            _DetailRow(Icons.business_outlined, 'Department', s.department),
            _DetailRow(Icons.badge_outlined, 'Role', s.role),
            _DetailRow(
              Icons.calendar_today_outlined,
              'Joined',
              DateFormat('MMM dd, yyyy').format(s.joinDate),
            ),
            _DetailRow(
              Icons.work_history_outlined,
              'Experience',
              '${DateTime.now().year - s.joinDate.year} year(s)',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        side: BorderSide(
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.5))),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openForm(existing: s);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(
                        s.isActive ? 'Mark On Leave' : 'Mark Active'),
                    style: FilledButton.styleFrom(
                        backgroundColor: s.isActive
                            ? Colors.orange
                            : AppTheme.successGreen),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _toggleStatus(s);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Add / Edit Form ───────────────────────────────────────────────────────

  void _openForm({StaffModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final emailCtrl =
        TextEditingController(text: existing?.email ?? '');
    final phoneCtrl =
        TextEditingController(text: existing?.phone ?? '');
    String role = existing?.role ?? _kRoles.first;
    String department = existing?.department ?? _kDepartments.first;
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
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
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  // drag handle
                  Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(2))),
                  ),
                  Text(
                    isEdit ? 'Edit Staff Member' : 'Add New Staff Member',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    ctrl: nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    ctrl: emailCtrl,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v == null || !v.contains('@')
                            ? 'Valid email required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    ctrl: phoneCtrl,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _kRoles
                        .map((r) =>
                            DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => role = v ?? role),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: department,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      prefixIcon: Icon(Icons.business_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _kDepartments
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => department = v ?? department),
                  ),
                  const SizedBox(height: 12),
                  // Active toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.toggle_on_outlined,
                            color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                            child: Text('Status',
                                style: TextStyle(fontSize: 15))),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isActive ? 'Active' : 'On Leave',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: isActive
                                      ? AppTheme.successGreen
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600),
                            ),
                            Switch(
                              value: isActive,
                              activeThumbColor: AppTheme.successGreen,
                              onChanged: (v) =>
                                  setLocal(() => isActive = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ??
                          false)) {
                        return;
                      }
                      final updated = StaffModel(
                        id: existing?.id ??
                            'staff_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                        role: role,
                        department: department,
                        isActive: isActive,
                        joinDate: existing?.joinDate ?? DateTime.now(),
                      );
                      setState(() {
                        if (isEdit) {
                          final i = _staff
                              .indexWhere((e) => e.id == existing.id);
                          if (i != -1) _staff[i] = updated;
                        } else {
                          _staff.add(updated);
                        }
                      });
                      Navigator.of(ctx).pop();
                      _snack(isEdit
                          ? '${updated.name} updated.'
                          : '${updated.name} added to staff.');
                    },
                    style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14)),
                    child: Text(
                        isEdit ? 'Save Changes' : 'Add Staff Member'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final totalActive =
        _staff.where((s) => s.isActive).length;
    final totalOnLeave = _staff.length - totalActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Management',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // ── Stats banner ─────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1D4ED8),
                  Color(0xFF2563EB),
                  Color(0xFF60A5FA)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color:
                        AppTheme.primaryBlue.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                    icon: Icons.groups,
                    label: 'Total',
                    value: '${_staff.length}'),
                Container(
                    width: 1, height: 36, color: Colors.white24),
                _StatItem(
                    icon: Icons.check_circle_outline,
                    label: 'Active',
                    value: '$totalActive'),
                Container(
                    width: 1, height: 36, color: Colors.white24),
                _StatItem(
                    icon: Icons.do_not_disturb_on_outlined,
                    label: 'On Leave',
                    value: '$totalOnLeave'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Search bar ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search by name, role or department…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _search = ''),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Role filter chips ─────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _roles.length,
              itemBuilder: (_, idx) {
                final r = _roles[idx];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(r,
                        style: const TextStyle(fontSize: 12)),
                    selected: _roleFilter == r,
                    selectedColor:
                        AppTheme.primaryBlue.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                        fontWeight: _roleFilter == r
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _roleFilter == r
                            ? AppTheme.primaryBlue
                            : null),
                    onSelected: (_) =>
                        setState(() => _roleFilter = r),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // ── Staff list ───────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_search,
                            size: 56,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('No staff members found',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final s = filtered[idx];
                      return _StaffCard(
                        staff: s,
                        onTap: () => _viewProfile(s),
                        onEdit: () => _openForm(existing: s),
                        onDelete: () => _confirmDelete(s),
                        onToggle: () => _toggleStatus(s),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }
}

// ── Staff card ────────────────────────────────────────────────────────────────
class _StaffCard extends StatelessWidget {
  final StaffModel staff;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _StaffCard({
    required this.staff,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final s = staff;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1.5,
      shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              MockAvatarWidget(name: s.name, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s.role,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryBlue)),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.business_outlined,
                            size: 12,
                            color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(s.department,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(s.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: s.isActive
                            ? AppTheme.successGreen.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.isActive ? 'Active' : 'On Leave',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: s.isActive
                                ? AppTheme.successGreen
                                : Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onEdit,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.edit_outlined,
                              size: 18,
                              color: AppTheme.primaryBlue),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_outline,
                              size: 18,
                              color: AppTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(
      {required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryBlue),
          const SizedBox(width: 10),
          SizedBox(
              width: 90,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500))),
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
  final int? maxLines;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
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
