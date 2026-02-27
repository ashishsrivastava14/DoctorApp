import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../features/auth/auth_notifier.dart';

class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card
          Card(
            child: ListTile(
              leading: const MockAvatarWidget(
                  name: 'Admin User', size: 44, avatarUrl: 'assets/images/avatars/admin.jpg'),
              title: const Text('Admin User',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('System Administrator'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/admin/profile'),
            ),
          ),
          const SizedBox(height: 16),

          // Management
          const Text('Management',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.apartment,
                  label: 'Departments',
                  color: Colors.purple,
                  onTap: () => context.push('/admin/departments'),
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.badge_outlined,
                  label: 'Staff Management',
                  color: Colors.teal,
                  onTap: () => context.push('/admin/staff'),
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.receipt_long,
                  label: 'Billing & Payments',
                  color: Colors.orange,
                  onTap: () => context.push('/admin/billing'),
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.assessment,
                  label: 'Reports & Analytics',
                  color: AppTheme.primaryBlue,
                  onTap: () => context.push('/admin/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // System
          const Text('System',
              style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  color: Colors.grey,
                  onTap: () => context.push('/admin/settings'),
                ),
                const Divider(height: 1),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  color: AppTheme.primaryBlue,
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
              icon: const Icon(Icons.logout, color: AppTheme.errorRed),
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  Color get _lighter {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, _lighter],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
