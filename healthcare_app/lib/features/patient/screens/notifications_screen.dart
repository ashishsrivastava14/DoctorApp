import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_notifications.dart';
import '../../../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  final String role;
  const NotificationsScreen({super.key, this.role = 'patient'});

  @override
  Widget build(BuildContext context) {
    final notifications = mockNotifications
        .where((n) => n.role == role || n.role == 'all')
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final today = notifications
        .where((n) =>
            DateFormat('yyyy-MM-dd').format(n.timestamp) ==
            DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .toList();
    final earlier = notifications
        .where((n) =>
            DateFormat('yyyy-MM-dd').format(n.timestamp) !=
            DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All marked as read')),
              );
            },
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (today.isNotEmpty) ...[
                  const Text('Today',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...today.map((n) => _NotificationTile(notification: n)),
                ],
                if (earlier.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Earlier',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  ...earlier.map((n) => _NotificationTile(notification: n)),
                ],
              ],
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  IconData get _icon {
    switch (notification.type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'prescription':
        return Icons.medication;
      case 'lab_result':
        return Icons.science;
      case 'payment':
        return Icons.payment;
      case 'reminder':
        return Icons.alarm;
      case 'system':
        return Icons.info_outline;
      default:
        return Icons.notifications;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'appointment':
        return AppTheme.primaryBlue;
      case 'prescription':
        return AppTheme.successGreen;
      case 'lab_result':
        return Colors.purple;
      case 'payment':
        return Colors.orange;
      case 'reminder':
        return AppTheme.warningAmber;
      case 'system':
        return Colors.grey;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(notification.timestamp);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _iconColor,
                HSLColor.fromColor(_iconColor)
                    .withLightness((HSLColor.fromColor(_iconColor).lightness + 0.15).clamp(0.0, 1.0))
                    .toColor(),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _iconColor.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(_icon, color: Colors.white, size: 20),
        ),
        title: Text(notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.w400 : FontWeight.w600,
              fontSize: 14,
            )),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(timeAgo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd').format(dt);
  }
}
