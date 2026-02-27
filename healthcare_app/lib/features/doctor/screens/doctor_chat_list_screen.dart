import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';

class DoctorChatListScreen extends StatelessWidget {
  const DoctorChatListScreen({super.key});

  static const _chats = [
    _ChatPreview(
        patientName: 'John Smith',
        lastMessage: 'Thank you, Doctor! I\'ll follow your advice.',
        time: '10:12 AM',
        unread: 0),
    _ChatPreview(
        patientName: 'Jane Doe',
        lastMessage: 'When should I come for the next check-up?',
        time: '9:45 AM',
        unread: 2),
    _ChatPreview(
        patientName: 'Robert Johnson',
        lastMessage: 'I\'m feeling much better now.',
        time: 'Yesterday',
        unread: 0),
    _ChatPreview(
        patientName: 'Emily Chen',
        lastMessage: 'Can I share my lab reports?',
        time: 'Yesterday',
        unread: 1),
    _ChatPreview(
        patientName: 'Michael Brown',
        lastMessage: 'The new medication is working well.',
        time: 'Mon',
        unread: 0),
    _ChatPreview(
        patientName: 'Sarah Williams',
        lastMessage: 'Should I continue the same dosage?',
        time: 'Mon',
        unread: 3),
    _ChatPreview(
        patientName: 'David Lee',
        lastMessage: 'Thank you for the prescription.',
        time: 'Sun',
        unread: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, indent: 72, color: Colors.grey.shade200),
        itemBuilder: (context, idx) {
          final chat = _chats[idx];
          return ListTile(
            leading: MockAvatarWidget(
                name: chat.patientName, size: 48),
            title: Row(
              children: [
                Expanded(
                  child: Text(chat.patientName,
                      style: TextStyle(
                        fontWeight: chat.unread > 0
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                      )),
                ),
                Text(chat.time,
                    style: TextStyle(
                        fontSize: 11,
                        color: chat.unread > 0
                            ? AppTheme.primaryBlue
                            : Colors.grey)),
              ],
            ),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: chat.unread > 0
                          ? Colors.black87
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (chat.unread > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${chat.unread}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              context.push('/doctor/chat');
            },
          );
        },
      ),
    );
  }
}

class _ChatPreview {
  final String patientName;
  final String lastMessage;
  final String time;
  final int unread;
  const _ChatPreview({
    required this.patientName,
    required this.lastMessage,
    required this.time,
    required this.unread,
  });
}
