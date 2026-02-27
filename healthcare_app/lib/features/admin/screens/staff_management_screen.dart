import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_staff.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() =>
      _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  String _roleFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final roles = ['All', ...{...mockStaff.map((s) => s.role)}];
    var staff = mockStaff.toList();
    if (_roleFilter != 'All') {
      staff = staff.where((s) => s.role == _roleFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              itemCount: roles.length,
              itemBuilder: (_, idx) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(roles[idx],
                      style: const TextStyle(fontSize: 12)),
                  selected: _roleFilter == roles[idx],
                  selectedColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                  onSelected: (_) =>
                      setState(() => _roleFilter = roles[idx]),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: staff.length,
              itemBuilder: (ctx, idx) {
                final s = staff[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: MockAvatarWidget(
                        name: s.name, size: 44),
                    title: Text(s.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.role,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryBlue)),
                        Text(
                          s.department,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: s.isActive
                            ? AppTheme.successGreen
                                .withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.isActive ? 'Active' : 'On Leave',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: s.isActive
                              ? AppTheme.successGreen
                              : Colors.grey,
                        ),
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add staff member (mock)')),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }
}
