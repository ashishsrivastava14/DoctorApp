import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../features/auth/auth_notifier.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;

  static const _activityLog = [
    (action: 'Logged in', time: '2h ago', icon: Icons.login),
    (action: 'Updated doctor schedule', time: '5h ago', icon: Icons.edit_calendar),
    (action: 'Added new doctor', time: 'Yesterday', icon: Icons.person_add),
    (action: 'Generated monthly report', time: '2 days ago', icon: Icons.assessment),
    (action: 'Modified billing settings', time: '3 days ago', icon: Icons.payment),
    (action: 'Approved staff request', time: '4 days ago', icon: Icons.check_circle_outline),
    (action: 'System settings updated', time: '1 week ago', icon: Icons.settings),
  ];

  static const _permissions = [
    (label: 'Manage Doctors', access: 'Full Access', icon: Icons.medical_services_outlined),
    (label: 'Manage Patients', access: 'Full Access', icon: Icons.people_outline),
    (label: 'Billing & Finance', access: 'Full Access', icon: Icons.payment_outlined),
    (label: 'Reports & Analytics', access: 'View & Export', icon: Icons.assessment_outlined),
    (label: 'Staff Management', access: 'Full Access', icon: Icons.badge_outlined),
    (label: 'System Settings', access: 'Modify', icon: Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: 'Admin User');
    _emailCtrl = TextEditingController(text: 'admin@healthcare.com');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final tempName = TextEditingController(text: _nameCtrl.text);
    final tempEmail = TextEditingController(text: _emailCtrl.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tempName,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tempEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nameCtrl.text = tempName.text;
                _emailCtrl.text = tempEmail.text;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Profile updated successfully!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) => v == null || v.length < 6
                    ? 'Min 6 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
                validator: (v) =>
                    v != newCtrl.text ? 'Passwords do not match' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password changed successfully!')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showActivityLog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              children: [
                Icon(Icons.history, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Activity Log',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: _activityLog
                  .map((e) => ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(e.icon,
                              size: 18, color: AppTheme.primaryBlue),
                        ),
                        title: Text(e.action,
                            style: const TextStyle(fontSize: 14)),
                        subtitle: Text(e.time,
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showAdminPermissions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Row(
              children: [
                Icon(Icons.admin_panel_settings,
                    color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Admin Permissions',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Role: System Administrator',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ..._permissions.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(p.icon,
                            size: 18, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(p.label,
                            style: const TextStyle(fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p.access,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.successGreen,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    MockAvatarWidget(
                        name: _nameCtrl.text,
                        size: 80,
                        avatarUrl: 'assets/images/avatars/admin.jpg'),
                    const SizedBox(height: 12),
                    Text(_nameCtrl.text,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('System Administrator',
                        style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(_emailCtrl.text,
                        style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Admin options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppTheme.primaryBlue),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showEditProfileDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: AppTheme.primaryBlue),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history,
                        color: AppTheme.primaryBlue),
                    title: const Text('Activity Log'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showActivityLog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: AppTheme.primaryBlue),
                    title: const Text('Admin Permissions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showAdminPermissions,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authProvider.notifier).logout(),
                icon: const Icon(Icons.logout,
                    color: AppTheme.errorRed),
                label: const Text('Logout',
                    style: TextStyle(color: AppTheme.errorRed)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
