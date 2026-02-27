import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_patients.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    var patients = mockPatients.toList();
    if (_search.isNotEmpty) {
      patients = patients
          .where(
              (p) => p.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Patients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search patients...',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${patients.length} patients',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: patients.length,
              itemBuilder: (ctx, idx) {
                final p = patients[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        MockAvatarWidget(name: p.name, size: 44, avatarUrl: p.avatarUrl),
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
                              Text(
                                '${p.age}y • ${p.gender} • ${p.bloodGroup}',
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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (p.allergies.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${p.allergies.length} allergies',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.errorRed),
                                ),
                              ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                                value: 'view', child: Text('View Details')),
                            const PopupMenuItem(
                                value: 'history',
                                child: Text('Medical History')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Remove',
                                    style: TextStyle(
                                        color: AppTheme.errorRed))),
                          ],
                          onSelected: (v) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('$v action on ${p.name}')),
                            );
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
    );
  }
}
