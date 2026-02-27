import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_departments.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: mockDepartments.length,
        itemBuilder: (ctx, idx) {
          final dept = mockDepartments[idx];
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
                              AppTheme.primaryBlue,
                              AppTheme.primaryBlue.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.3),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(dept.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _DeptStat(
                          icon: Icons.medical_services,
                          value: '${dept.doctorCount}',
                          label: 'Doctors'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('View ${dept.name} details')),
                          );
                        },
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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add department (mock)')),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
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
    return Icons.local_hospital;
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
