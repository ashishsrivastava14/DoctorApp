import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_doctors.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});

  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  String _search = '';
  String _specialtyFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final specialties = [
      'All',
      ...{...mockDoctors.map((d) => d.specialty)}
    ];

    var doctors = mockDoctors.toList();
    if (_search.isNotEmpty) {
      doctors = doctors
          .where(
              (d) => d.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    if (_specialtyFilter != 'All') {
      doctors = doctors
          .where((d) => d.specialty == _specialtyFilter)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctors')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search doctors...',
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
              itemCount: specialties.length,
              itemBuilder: (_, idx) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(specialties[idx],
                      style: const TextStyle(fontSize: 12)),
                  selected: _specialtyFilter == specialties[idx],
                  selectedColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.15),
                  onSelected: (_) =>
                      setState(() => _specialtyFilter = specialties[idx]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${doctors.length} doctors',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: doctors.length,
              itemBuilder: (ctx, idx) {
                final doc = doctors[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        MockAvatarWidget(name: doc.name, size: 48, avatarUrl: doc.avatarUrl),
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
                                '${doc.experienceYears} yrs exp • ${doc.patientCount} patients',
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
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc.isAvailable ? 'Active' : 'Inactive',
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
                                value: 'view', child: Text('View Profile')),
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(
                                value: 'toggle',
                                child: Text('Toggle Status')),
                            const PopupMenuItem(
                                value: 'delete',
                                child: Text('Remove',
                                    style: TextStyle(
                                        color: AppTheme.errorRed))),
                          ],
                          onSelected: (v) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '$v action on ${doc.name}')),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add doctor form (mock)')),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Doctor'),
      ),
    );
  }
}
