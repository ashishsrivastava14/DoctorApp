import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  final String doctorName;
  final String doctorAvatarUrl;
  const ChatScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Wilson',
    this.doctorAvatarUrl = 'assets/images/avatars/doctor_2.jpg',
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<_ChatMsg> _messages = [
    _ChatMsg(
      text: 'Hello! How are you feeling today?',
      isDoctor: true,
      time: '10:00 AM',
    ),
    _ChatMsg(
      text: 'Hi Doctor, I\'ve been having a mild headache for 2 days.',
      isDoctor: false,
      time: '10:02 AM',
    ),
    _ChatMsg(
      text:
          'I see. Is it constant or does it come and go? Any other symptoms like nausea or vision changes?',
      isDoctor: true,
      time: '10:03 AM',
    ),
    _ChatMsg(
      text:
          'It comes and goes. No nausea but my eyes feel a bit strained, probably from too much screen time.',
      isDoctor: false,
      time: '10:05 AM',
    ),
    _ChatMsg(
      text:
          'That\'s a common cause. I\'d recommend taking regular breaks from screens using the 20-20-20 rule. Also make sure you\'re staying hydrated.',
      isDoctor: true,
      time: '10:06 AM',
    ),
    _ChatMsg(
      text: 'What\'s the 20-20-20 rule?',
      isDoctor: false,
      time: '10:07 AM',
    ),
    _ChatMsg(
      text:
          'Every 20 minutes, look at something 20 feet away for 20 seconds. It helps reduce eye strain significantly.',
      isDoctor: true,
      time: '10:08 AM',
    ),
    _ChatMsg(
      text: 'That\'s helpful, thank you! Should I take any medication?',
      isDoctor: false,
      time: '10:09 AM',
    ),
    _ChatMsg(
      text:
          'You can take Paracetamol 500mg if the headache is bothering you. No more than 3 times a day. If it persists for more than a week, schedule a visit.',
      isDoctor: true,
      time: '10:10 AM',
    ),
    _ChatMsg(
      text: 'Thank you, Doctor! I\'ll follow your advice.',
      isDoctor: false,
      time: '10:12 AM',
    ),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(
        text: text,
        isDoctor: false,
        time: TimeOfDay.now().format(context),
      ));
    });
    _msgCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // Simulate doctor reply
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMsg(
          text: 'Thank you for sharing that. Let me review and get back to you.',
          isDoctor: true,
          time: TimeOfDay.now().format(context),
        ));
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            MockAvatarWidget(name: widget.doctorName, size: 36, avatarUrl: widget.doctorAvatarUrl),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const Text('Online',
                    style: TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Date separator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Today',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                return _ChatBubble(msg: msg);
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Attachment feature (mock)')),
                      );
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMsg {
  final String text;
  final bool isDoctor;
  final String time;
  const _ChatMsg(
      {required this.text, required this.isDoctor, required this.time});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isMe = !msg.isDoctor;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.primaryBlue
              : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              msg.time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white60 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
