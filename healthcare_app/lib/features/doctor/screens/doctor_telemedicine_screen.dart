import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../models/appointment_model.dart';

class DoctorTelemedicineScreen extends StatefulWidget {
  const DoctorTelemedicineScreen({super.key});

  @override
  State<DoctorTelemedicineScreen> createState() =>
      _DoctorTelemedicineScreenState();
}

class _DoctorTelemedicineScreenState
    extends State<DoctorTelemedicineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show all online appointments across all doctors for demo purposes.
    // In production this would be filtered by auth.userId.
    final allOnline = mockAppointments
        .where((a) => a.type == 'Online')
        .toList();

    final upcoming = allOnline
        .where((a) =>
            (a.status == 'Confirmed' || a.status == 'Pending') &&
            a.date.isAfter(DateTime(2026, 2, 28)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final past = allOnline
        .where((a) =>
            a.status == 'Completed' ||
            (!a.date.isAfter(DateTime(2026, 2, 28))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Telemedicine',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Stats Banner ───────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Online',
                  value: '${allOnline.length}',
                  icon: Icons.videocam,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _StatItem(
                  label: 'Upcoming',
                  value: '${upcoming.length}',
                  icon: Icons.schedule,
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _StatItem(
                  label: 'Completed',
                  value: '${past.length}',
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),

          // ── Tab Views ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AppointmentList(
                  appointments: upcoming,
                  emptyMessage: 'No upcoming telemedicine appointments',
                  emptyIcon: Icons.videocam_off_outlined,
                  isUpcoming: true,
                ),
                _AppointmentList(
                  appointments: past,
                  emptyMessage: 'No completed telemedicine sessions',
                  emptyIcon: Icons.history,
                  isUpcoming: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appointment list tab ──────────────────────────────────────────────────────
class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool isUpcoming;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: appointments.length,
      itemBuilder: (context, i) {
        final appt = appointments[i];
        return _TelemedicineCard(appt: appt, isUpcoming: isUpcoming);
      },
    );
  }
}

// ── Single appointment card ───────────────────────────────────────────────────
class _TelemedicineCard extends StatelessWidget {
  final AppointmentModel appt;
  final bool isUpcoming;

  const _TelemedicineCard({required this.appt, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(appt.date) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date / time row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12,
                          color: isToday
                              ? AppTheme.successGreen
                              : AppTheme.primaryBlue),
                      const SizedBox(width: 5),
                      Text(
                        isToday
                            ? 'Today'
                            : DateFormat('MMM dd, yyyy').format(appt.date),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? AppTheme.successGreen
                                : AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 5),
                      Text(appt.timeSlot,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(appt.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(appt.status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(appt.status))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Patient info
            Row(
              children: [
                MockAvatarWidget(
                    name: appt.patientName, size: 48, avatarUrl: appt.patientAvatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appt.patientName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.videocam,
                              size: 14, color: AppTheme.primaryBlue),
                          const SizedBox(width: 4),
                          Text('Online Consultation',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                      if (appt.notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(appt.notes,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Text('\$${appt.fee.toInt()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.successGreen)),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            if (isUpcoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Message'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: BorderSide(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.videocam, size: 16),
                      label: const Text('Join Call'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                      onPressed: () => _startCall(context, appt),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppTheme.successGreen, size: 16),
                  const SizedBox(width: 6),
                  Text('Session completed',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View Notes'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return AppTheme.successGreen;
      case 'Pending':
        return AppTheme.warningAmber;
      case 'Completed':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.errorRed;
    }
  }

  void _startCall(BuildContext context, AppointmentModel appt) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _DoctorCallScreen(appointment: appt),
    ));
  }
}

// ── In-call screen (doctor perspective) ──────────────────────────────────────
class _DoctorCallScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const _DoctorCallScreen({required this.appointment});

  @override
  State<_DoctorCallScreen> createState() => _DoctorCallScreenState();
}

class _DoctorCallScreenState extends State<_DoctorCallScreen> {
  bool _micOn = true;
  bool _cameraOn = true;
  bool _speakerOn = true;
  bool _chatOpen = false;

  // Simple elapsed timer display
  final String _callDuration = '00:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Patient video placeholder (full background) ────────────────
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade900,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MockAvatarWidget(
                    name: widget.appointment.patientName,
                    size: 100,
                    avatarUrl: widget.appointment.patientAvatar),
                const SizedBox(height: 16),
                Text(widget.appointment.patientName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Patient',
                    style:
                        TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fiber_manual_record,
                          color: AppTheme.successGreen, size: 10),
                      const SizedBox(width: 6),
                      Text('Connected  •  $_callDuration',
                          style: const TextStyle(
                              color: AppTheme.successGreen, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Doctor self-preview (top-right) ───────────────────────────
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 60,
            child: Container(
              width: 110,
              height: 150,
              decoration: BoxDecoration(
                color: _cameraOn ? Colors.grey.shade800 : Colors.black,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              ),
              child: _cameraOn
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person, color: Colors.white38, size: 40),
                        SizedBox(height: 4),
                        Text('You (Doctor)',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 10)),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off,
                            color: Colors.white38, size: 28),
                        SizedBox(height: 4),
                        Text('Camera off',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 10)),
                      ],
                    ),
            ),
          ),

          // ── Top bar ───────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                right: 8,
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Telemedicine Consultation',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        Text(widget.appointment.timeSlot,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _speakerOn ? Icons.volume_up : Icons.volume_down,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        setState(() => _speakerOn = !_speakerOn),
                  ),
                ],
              ),
            ),
          ),

          // ── Chat panel ────────────────────────────────────────────────
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
                        blurRadius: 10),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(16)),
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
                        children: [
                          _MiniChatBubble(
                              text:
                                  'Hello, can you describe your symptoms?',
                              isMe: true),
                          _MiniChatBubble(
                              text:
                                  'I have been experiencing chest pain for 2 days.',
                              isMe: false),
                          _MiniChatBubble(
                              text: 'Any shortness of breath?',
                              isMe: true),
                          _MiniChatBubble(
                              text: 'Occasionally, yes.',
                              isMe: false),
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
                                  borderRadius: BorderRadius.circular(20),
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

          // ── Bottom controls ───────────────────────────────────────────
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
                  _ControlBtn(
                    icon: _micOn ? Icons.mic : Icons.mic_off,
                    label: _micOn ? 'Mute' : 'Unmute',
                    active: _micOn,
                    onTap: () => setState(() => _micOn = !_micOn),
                  ),
                  _ControlBtn(
                    icon: _cameraOn ? Icons.videocam : Icons.videocam_off,
                    label: _cameraOn ? 'Camera' : 'Cam Off',
                    active: _cameraOn,
                    onTap: () => setState(() => _cameraOn = !_cameraOn),
                  ),
                  // End call
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                          color: AppTheme.errorRed, shape: BoxShape.circle),
                      child: const Icon(Icons.call_end,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  _ControlBtn(
                    icon: Icons.chat_bubble_outline,
                    label: 'Chat',
                    active: _chatOpen,
                    onTap: () =>
                        setState(() => _chatOpen = !_chatOpen),
                  ),
                  _ControlBtn(
                    icon: Icons.note_add_outlined,
                    label: 'Notes',
                    active: false,
                    onTap: () => _showNotesSheet(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consultation Notes',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const TextField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText:
                        'Write notes about this consultation...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Save Notes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlBtn(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
  final bool isMe;
  const _MiniChatBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}
