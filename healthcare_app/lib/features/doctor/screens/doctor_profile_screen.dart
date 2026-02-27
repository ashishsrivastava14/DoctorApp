import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../features/auth/auth_notifier.dart';
import '../../../mock_data/mock_doctors.dart';

class DoctorProfileScreen extends ConsumerStatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  ConsumerState<DoctorProfileScreen> createState() =>
      _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends ConsumerState<DoctorProfileScreen> {
  bool _editing = false;
  late TextEditingController _phoneCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _feeCtrl;

  @override
  void initState() {
    super.initState();
    final doctor = mockDoctors.first;
    _phoneCtrl = TextEditingController(text: doctor.phone);
    _bioCtrl = TextEditingController(text: doctor.bio);
    _feeCtrl = TextEditingController(
        text: doctor.consultationFee.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final doctor = mockDoctors.firstWhere(
      (d) => d.id == auth.userId,
      orElse: () => mockDoctors.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton(
            onPressed: () {
              if (_editing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!')),
                );
              }
              setState(() => _editing = !_editing);
            },
            child: Text(
              _editing ? 'Save' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Hero(
                      tag: 'doctor_${doctor.id}',
                      child: MockAvatarWidget(
                          name: doctor.name, size: 80, avatarUrl: doctor.avatarUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(doctor.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text(doctor.specialty,
                        style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlue)),
                    const SizedBox(height: 4),
                    Text(doctor.hospitalName,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                            value: '${doctor.patientCount}',
                            label: 'Patients'),
                        _StatItem(
                            value: '${doctor.experienceYears} yrs',
                            label: 'Experience'),
                        _StatItem(
                            value: doctor.rating.toStringAsFixed(1),
                            label: 'Rating'),
                        _StatItem(
                            value: '${doctor.reviewCount}',
                            label: 'Reviews'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Contact Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact Information',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.email_outlined,
                          color: AppTheme.primaryBlue),
                      title: Text(doctor.email),
                      contentPadding: EdgeInsets.zero,
                    ),
                    TextFormField(
                      controller: _phoneCtrl,
                      enabled: _editing,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Professional Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Professional Details',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _feeCtrl,
                      enabled: _editing,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Consultation Fee (\$)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bioCtrl,
                      enabled: _editing,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Qualifications',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [doctor.education]
                          .map((q) => Chip(
                                label: Text(q,
                                    style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppTheme.primaryBlue
                                    .withValues(alpha: 0.08),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Available Days',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: doctor.availableDays
                          .map((d) => Chip(
                                label: Text(d,
                                    style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}
