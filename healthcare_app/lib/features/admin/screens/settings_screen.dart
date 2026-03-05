import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../features/auth/auth_notifier.dart';

// ── Available languages ───────────────────────────────────────────────────────
const _kLanguages = [
  'English',
  'Spanish',
  'French',
  'German',
  'Arabic',
  'Hindi',
  'Chinese (Simplified)',
  'Portuguese',
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Notification toggles
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsAlerts = false;

  // Security toggles
  bool _biometrics = false;
  bool _twoFactor = false;

  // System
  String _language = 'English';

  // ── helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? AppTheme.errorRed : null,
      ),
    );
  }

  // ── Language picker ───────────────────────────────────────────────────────

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Select Language',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _kLanguages.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1),
              itemBuilder: (_, i) {
                final lang = _kLanguages[i];
                final selected = lang == _language;
                return ListTile(
                  title: Text(lang),
                  trailing: selected
                      ? const Icon(Icons.check,
                          color: AppTheme.primaryBlue)
                      : null,
                  tileColor: selected
                      ? AppTheme.primaryBlue.withValues(alpha: 0.05)
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    Navigator.of(ctx).pop();
                    _snack('Language changed to $lang');
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Backup & Restore ──────────────────────────────────────────────────────

  void _showBackupSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
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
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text('Backup & Restore',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Last backup: Today, 09:15 AM',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            _BackupOption(
              icon: Icons.cloud_upload_outlined,
              color: AppTheme.primaryBlue,
              title: 'Back Up Now',
              subtitle: 'Upload data to secure cloud storage',
              onTap: () {
                Navigator.of(ctx).pop();
                _snack('Backup started… data uploaded successfully.');
              },
            ),
            const SizedBox(height: 10),
            _BackupOption(
              icon: Icons.cloud_download_outlined,
              color: AppTheme.successGreen,
              title: 'Restore from Backup',
              subtitle: 'Restore the most recent cloud backup',
              onTap: () {
                Navigator.of(ctx).pop();
                _showRestoreConfirm();
              },
            ),
            const SizedBox(height: 10),
            _BackupOption(
              icon: Icons.delete_sweep_outlined,
              color: AppTheme.errorRed,
              title: 'Clear Local Cache',
              subtitle: 'Free up storage by clearing cached files',
              onTap: () {
                Navigator.of(ctx).pop();
                _snack('Local cache cleared (42 MB freed).');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreConfirm() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
            'This will overwrite current data with the last backup. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.successGreen),
            onPressed: () {
              Navigator.of(ctx).pop();
              _snack('Restore complete. Data updated from backup.');
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  // ── Security ──────────────────────────────────────────────────────────────

  void _showSecuritySheet() {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Security',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.fingerprint,
                    color: AppTheme.primaryBlue),
                title: const Text('Biometric Login'),
                subtitle: const Text(
                    'Use fingerprint or Face ID to sign in'),
                value: _biometrics,
                onChanged: (v) {
                  setState(() => _biometrics = v);
                  setLocal(() {});
                  _snack(v
                      ? 'Biometric login enabled.'
                      : 'Biometric login disabled.');
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.verified_user_outlined,
                    color: AppTheme.primaryBlue),
                title: const Text('Two-Factor Authentication'),
                subtitle:
                    const Text('Add an extra layer of security'),
                value: _twoFactor,
                onChanged: (v) {
                  setState(() => _twoFactor = v);
                  setLocal(() {});
                  _snack(v
                      ? '2FA enabled.'
                      : '2FA disabled.');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline,
                    color: AppTheme.primaryBlue),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showChangePasswordDialog();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.devices_outlined,
                    color: AppTheme.primaryBlue),
                title: const Text('Active Sessions'),
                subtitle:
                    const Text('2 devices currently signed in'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showActiveSessionsDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
                    border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder()),
                validator: (v) => v == null || v.length < 6
                    ? 'Min 6 characters'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder()),
                validator: (v) => v != newCtrl.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop();
                _snack('Password changed successfully.');
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Active Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SessionTile(
                device: 'iPhone 15 Pro',
                location: 'New York, US',
                isCurrent: true,
                onRevoke: null),
            const Divider(),
            _SessionTile(
                device: 'Chrome — Windows',
                location: 'New York, US',
                isCurrent: false,
                onRevoke: () {
                  Navigator.of(ctx).pop();
                  _snack('Session revoked for Chrome — Windows.');
                }),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close')),
        ],
      ),
    );
  }

  // ── Policy sheets ─────────────────────────────────────────────────────────

  void _showPolicySheet(String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(title,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Last updated: January 1, 2026',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            Text(body,
                style: const TextStyle(
                    fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }

  // ── Logout confirmation ───────────────────────────────────────────────────

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.errorRed),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(color: Colors.white)),
        iconTheme:
            const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Appearance ──────────────────────────────────────────────
          _SectionHeader('Appearance'),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle:
                  const Text('Switch between light & dark theme'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: AppTheme.primaryBlue,
              ),
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Notifications ───────────────────────────────────────────
          _SectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle:
                      const Text('Receive push notifications'),
                  secondary: const Icon(Icons.notifications,
                      color: AppTheme.primaryBlue),
                  value: _pushNotifications,
                  onChanged: (v) {
                    setState(() => _pushNotifications = v);
                    _snack(v
                        ? 'Push notifications enabled.'
                        : 'Push notifications disabled.');
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle:
                      const Text('Receive email updates'),
                  secondary: const Icon(Icons.email,
                      color: AppTheme.primaryBlue),
                  value: _emailNotifications,
                  onChanged: (v) {
                    setState(() => _emailNotifications = v);
                    _snack(v
                        ? 'Email notifications enabled.'
                        : 'Email notifications disabled.');
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('SMS Alerts'),
                  subtitle: const Text(
                      'Receive SMS for appointments'),
                  secondary: const Icon(Icons.sms,
                      color: AppTheme.primaryBlue),
                  value: _smsAlerts,
                  onChanged: (v) {
                    setState(() => _smsAlerts = v);
                    _snack(v
                        ? 'SMS alerts enabled.'
                        : 'SMS alerts disabled.');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── System ──────────────────────────────────────────────────
          _SectionHeader('System'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language,
                      color: AppTheme.primaryBlue),
                  title: const Text('Language'),
                  subtitle: Text(_language),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLanguagePicker,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup,
                      color: AppTheme.primaryBlue),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Manage your data backups'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showBackupSheet,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security,
                      color: AppTheme.primaryBlue),
                  title: const Text('Security'),
                  subtitle: Text(
                    [
                      if (_biometrics) 'Biometrics',
                      if (_twoFactor) '2FA',
                    ].isEmpty
                        ? 'Password only'
                        : [
                            if (_biometrics) 'Biometrics',
                            if (_twoFactor) '2FA',
                          ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showSecuritySheet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── About ────────────────────────────────────────────────────
          _SectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppTheme.primaryBlue),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Build 1)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description,
                      color: AppTheme.primaryBlue),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPolicySheet(
                    'Terms of Service',
                    'By using HealthCare, you agree to the following terms and conditions.\n\n'
                        '1. Use of Service\nHealthCare provides a platform for connecting patients with healthcare providers. '
                        'You agree to provide accurate and complete information when creating your account.\n\n'
                        '2. Medical Disclaimer\nHealthCare does not provide medical advice. '
                        'Consultations on this platform are for informational purposes only. '
                        'Always seek in-person care for emergencies.\n\n'
                        '3. Account Responsibility\nYou are responsible for maintaining the confidentiality of your account credentials '
                        'and for all activities that occur under your account.\n\n'
                        '4. Data & Privacy\nWe collect and process personal data as described in our Privacy Policy. '
                        'By using HealthCare, you consent to such processing.\n\n'
                        '5. Modifications\nWe reserve the right to update these terms at any time. '
                        'Continued use of the service after changes constitutes acceptance.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip,
                      color: AppTheme.primaryBlue),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPolicySheet(
                    'Privacy Policy',
                    'Your privacy is important to us. This policy explains how HealthCare collects, uses, and safeguards your information.\n\n'
                        '1. Information We Collect\nWe collect personal information you provide (name, email, phone, health data) '
                        'and usage data (device info, app interactions).\n\n'
                        '2. How We Use Information\nWe use your data to provide and improve our services, '
                        'facilitate appointments, send notifications, and comply with legal obligations.\n\n'
                        '3. Data Sharing\nWe do not sell your personal information. '
                        'We may share data with healthcare providers you interact with and trusted service partners under strict confidentiality agreements.\n\n'
                        '4. Data Security\nWe implement industry-standard encryption and security measures to protect your data.\n\n'
                        '5. Your Rights\nYou may request access to, correction of, or deletion of your personal data at any time by contacting support.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Logout ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout,
                  color: AppTheme.errorRed),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.errorRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorRed),
                padding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

class _BackupOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BackupOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final String device;
  final String location;
  final bool isCurrent;
  final VoidCallback? onRevoke;

  const _SessionTile({
    required this.device,
    required this.location,
    required this.isCurrent,
    required this.onRevoke,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.phone_android,
          color: isCurrent
              ? AppTheme.successGreen
              : AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(device,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              Text(location,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary)),
              if (isCurrent)
                Text('This device',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (!isCurrent && onRevoke != null)
          TextButton(
            onPressed: onRevoke,
            child: const Text('Revoke',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
      ],
    );
  }
}
