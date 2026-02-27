import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';

class TelemedicineScreen extends StatefulWidget {
  const TelemedicineScreen({super.key});

  @override
  State<TelemedicineScreen> createState() => _TelemedicineScreenState();
}

class _TelemedicineScreenState extends State<TelemedicineScreen> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _speakerOn = false;
  bool _chatOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Doctor Video Placeholder (large area)
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade900,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MockAvatarWidget(
                      name: 'Dr. Sarah Wilson', size: 100),
                  const SizedBox(height: 16),
                  const Text(
                    'Dr. Sarah Wilson',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cardiologist',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: AppTheme.successGreen, size: 10),
                        SizedBox(width: 6),
                        Text('Connected  •  12:34',
                            style: TextStyle(
                                color: AppTheme.successGreen,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Self Video Preview (small, bottom-right)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 60,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                color: _cameraOn ? Colors.grey.shade800 : Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 2),
              ),
              child: _cameraOn
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.white38, size: 40),
                        SizedBox(height: 4),
                        Text('You',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off,
                            color: Colors.white38, size: 30),
                        SizedBox(height: 4),
                        Text('Camera off',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 10)),
                      ],
                    ),
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      children: [
                        Text('Telemedicine Consultation',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text('In Progress',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _speakerOn
                          ? Icons.volume_up
                          : Icons.volume_down,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        setState(() => _speakerOn = !_speakerOn),
                  ),
                ],
              ),
            ),
          ),

          // Chat Panel (sliding in from right)
          if (_chatOpen)
            Positioned(
              right: 0,
              top: MediaQuery.of(context).padding.top + 50,
              bottom: 100,
              width: MediaQuery.of(context).size.width * 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          const Text('Chat',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _chatOpen = false),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(12),
                        children: const [
                          _MiniChatBubble(
                              text: 'Can you describe the pain?',
                              isDoc: true),
                          _MiniChatBubble(
                              text:
                                  'It\'s a sharp pain on the left side of my chest.',
                              isDoc: false),
                          _MiniChatBubble(
                              text:
                                  'How long does each episode last?',
                              isDoc: true),
                          _MiniChatBubble(
                              text: 'About 2-3 minutes usually.',
                              isDoc: false),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Type message...',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: AppTheme.primaryBlue),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 16,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlButton(
                    icon: _micOn ? Icons.mic : Icons.mic_off,
                    label: _micOn ? 'Mute' : 'Unmute',
                    active: _micOn,
                    onPressed: () =>
                        setState(() => _micOn = !_micOn),
                  ),
                  _ControlButton(
                    icon: _cameraOn
                        ? Icons.videocam
                        : Icons.videocam_off,
                    label: _cameraOn ? 'Camera' : 'Camera Off',
                    active: _cameraOn,
                    onPressed: () =>
                        setState(() => _cameraOn = !_cameraOn),
                  ),
                  // End Call
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  _ControlButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    active: _chatOpen,
                    onPressed: () =>
                        setState(() => _chatOpen = !_chatOpen),
                  ),
                  _ControlButton(
                    icon: Icons.screen_share_outlined,
                    label: 'Share',
                    active: false,
                    onPressed: () {},
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

class _MiniChatBubble extends StatelessWidget {
  final String text;
  final bool isDoc;
  const _MiniChatBubble({required this.text, required this.isDoc});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isDoc ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDoc
              ? Colors.grey.shade200
              : AppTheme.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}
