import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../features/auth/auth_notifier.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

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
                    const MockAvatarWidget(
                        name: 'Admin User', size: 80, avatarUrl: 'assets/images/avatars/admin.jpg'),
                    const SizedBox(height: 12),
                    Text(auth.userName ?? 'Admin',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('System Administrator',
                        style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('admin@healthcare.com',
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
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: AppTheme.primaryBlue),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history,
                        color: AppTheme.primaryBlue),
                    title: const Text('Activity Log'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings,
                        color: AppTheme.primaryBlue),
                    title: const Text('Admin Permissions'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
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
                icon:
                    const Icon(Icons.logout, color: AppTheme.errorRed),
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
