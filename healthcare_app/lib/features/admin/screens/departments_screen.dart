import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_departments.dart';
import '../../../models/department_model.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  late List<DepartmentModel> _departments;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _departments = mockDepartments.toList();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  List<DepartmentModel> get _filtered {
    if (_search.isEmpty) return _departments;
    final q = _search.toLowerCase();
    return _departments
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q))
        .toList();
  }

  // ── View Details ──────────────────────────────────────────────────────────

  void _viewDetails(DepartmentModel dept) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_deptIcon(dept.name),
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dept.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: dept.isActive
                              ? AppTheme.successGreen
                                  .withValues(alpha: 0.1)
                              : AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dept.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: dept.isActive
                                  ? AppTheme.successGreen
                                  : AppTheme.errorRed),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            _DetailRow(
                icon: Icons.description_outlined,
                label: 'Description',
                value: dept.description),
            const SizedBox(height: 10),
            _DetailRow(
                icon: Icons.medical_services_outlined,
                label: 'Doctors',
                value: '${dept.doctorCount} assigned'),
            const SizedBox(height: 10),
            _DetailRow(
                icon: Icons.tag,
                label: 'Department ID',
                value: dept.id),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openForm(existing: dept);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                        dept.isActive
                            ? Icons.toggle_off_outlined
                            : Icons.toggle_on_outlined,
                        size: 16),
                    label: Text(
                        dept.isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: dept.isActive
                            ? AppTheme.warningAmber
                            : AppTheme.successGreen,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _toggleStatus(dept);
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

  void _openForm({DepartmentModel? existing}) {
    final isEdit = existing != null;
    final nameCtrl =
        TextEditingController(text: existing?.name ?? '');
    final descCtrl =
        TextEditingController(text: existing?.description ?? '');
    final doctorCountCtrl = TextEditingController(
        text: existing?.doctorCount.toString() ?? '0');
    bool isActive = existing?.isActive ?? true;
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
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  Text(isEdit ? 'Edit Department' : 'Add Department',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Department Name',
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: doctorCountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Doctors',
                      prefixIcon:
                          Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Active toggle
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        isActive
                            ? 'Department is currently active'
                            : 'Department is currently inactive',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    value: isActive,
                    activeColor: AppTheme.successGreen,
                    onChanged: (v) => setLocal(() => isActive = v),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ??
                            false)) return;
                        final updated = DepartmentModel(
                          id: existing?.id ??
                              'dept_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          icon: existing?.icon ?? '🏥',
                          doctorCount:
                              int.tryParse(doctorCountCtrl.text) ?? 0,
                          isActive: isActive,
                        );
                        setState(() {
                          if (isEdit) {
                            final i = _departments.indexWhere(
                                (d) => d.id == existing.id);
                            if (i != -1) _departments[i] = updated;
                          } else {
                            _departments.add(updated);
                          }
                        });
                        Navigator.of(ctx).pop();
                        _snack(isEdit
                            ? '${updated.name} updated.'
                            : '${updated.name} added.');
                      },
                      child: Text(
                          isEdit ? 'Save Changes' : 'Add Department'),
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

  // ── Toggle Active / Inactive ──────────────────────────────────────────────

  void _toggleStatus(DepartmentModel dept) {
    final idx = _departments.indexWhere((d) => d.id == dept.id);
    if (idx == -1) return;
    setState(() {
      _departments[idx] =
          _departments[idx].copyWith(isActive: !_departments[idx].isActive);
    });
    final status = _departments[idx].isActive ? 'Active' : 'Inactive';
    _snack('${dept.name} marked as $status.');
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  void _confirmDelete(DepartmentModel dept) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
            'Are you sure you want to delete "${dept.name}"? This cannot be undone.'),
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
                  () => _departments.removeWhere((d) => d.id == dept.id));
              Navigator.of(ctx).pop();
              _snack('${dept.name} deleted.');
            },
            child: const Text('Delete'),
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
      appBar: AppBar(
        title: const Text('Departments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search departments...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),
      body: displayed.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off,
                      size: 56, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No departments found',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: displayed.length,
              itemBuilder: (ctx, idx) {
                final dept = displayed[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    dept.isActive
                                        ? AppTheme.primaryBlue
                                        : Colors.grey.shade500,
                                    dept.isActive
                                        ? AppTheme.primaryBlue
                                            .withValues(alpha: 0.7)
                                        : Colors.grey.shade400,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: (dept.isActive
                                            ? AppTheme.primaryBlue
                                            : Colors.grey)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _deptIcon(dept.name),
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(dept.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  Text(dept.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: dept.isActive
                                    ? AppTheme.successGreen
                                        .withValues(alpha: 0.1)
                                    : AppTheme.errorRed
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dept.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: dept.isActive
                                      ? AppTheme.successGreen
                                      : AppTheme.errorRed,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'view',
                                    child: Row(children: [
                                      Icon(Icons.visibility_outlined,
                                          size: 18),
                                      SizedBox(width: 8),
                                      Text('View Details'),
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
                                          dept.isActive
                                              ? Icons.toggle_off_outlined
                                              : Icons.toggle_on_outlined,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(dept.isActive
                                          ? 'Deactivate'
                                          : 'Activate'),
                                    ])),
                                const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline,
                                          size: 18,
                                          color: AppTheme.errorRed),
                                      SizedBox(width: 8),
                                      Text('Delete',
                                          style: TextStyle(
                                              color: AppTheme.errorRed)),
                                    ])),
                              ],
                              onSelected: (v) {
                                switch (v) {
                                  case 'view':
                                    _viewDetails(dept);
                                    break;
                                  case 'edit':
                                    _openForm(existing: dept);
                                    break;
                                  case 'toggle':
                                    _toggleStatus(dept);
                                    break;
                                  case 'delete':
                                    _confirmDelete(dept);
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(dept.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _DeptStat(
                                icon: Icons.medical_services,
                                value: '${dept.doctorCount}',
                                label: 'Doctors'),
                            const Spacer(),
                            TextButton(
                              onPressed: () => _viewDetails(dept),
                              child: const Text('Details'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
      ),
    );
  }

  IconData _deptIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cardio')) return Icons.favorite;
    if (lower.contains('neuro')) return Icons.psychology;
    if (lower.contains('ortho')) return Icons.accessibility_new;
    if (lower.contains('pedia')) return Icons.child_care;
    if (lower.contains('dermato')) return Icons.face;
    if (lower.contains('ent')) return Icons.hearing;
    if (lower.contains('ophthal')) return Icons.visibility;
    if (lower.contains('oncol')) return Icons.biotech;
    if (lower.contains('gastro')) return Icons.local_dining;
    if (lower.contains('gynec')) return Icons.pregnant_woman;
    if (lower.contains('urolog')) return Icons.water_drop;
    if (lower.contains('pulmon')) return Icons.air;
    if (lower.contains('emergency')) return Icons.emergency;
    if (lower.contains('radiol')) return Icons.image_search;
    if (lower.contains('general')) return Icons.local_hospital;
    if (lower.contains('psychi')) return Icons.psychology_alt;
    return Icons.local_hospital;
  }
}

// ── Detail row widget ─────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _DeptStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _DeptStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text('$value $label',
            style: TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }
}
