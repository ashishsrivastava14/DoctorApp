import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/mock_avatar_widget.dart';

// ── Reusable call sheet ───────────────────────────────────────────────────────
void _showCallSheet(BuildContext context,
    {required bool isVideo, required String name}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.12),
              child: Icon(
                isVideo ? Icons.videocam : Icons.call,
                size: 36,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isVideo ? 'Video Call' : 'Voice Call',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(name,
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 6),
            Text(
              'Connecting...',
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primaryBlue,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _CallAction(
                  icon: Icons.mic_off,
                  label: 'Mute',
                  color: Colors.grey.shade700,
                  onTap: () {},
                ),
                if (isVideo)
                  _CallAction(
                    icon: Icons.videocam_off,
                    label: 'Camera',
                    color: Colors.grey.shade700,
                    onTap: () {},
                  ),
                _CallAction(
                  icon: Icons.call_end,
                  label: 'End',
                  color: Colors.red,
                  onTap: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CallAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Attachment sheet ──────────────────────────────────────────────────────────
void _showAttachmentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showGallerySheet(context);
                  },
                ),
                _AttachOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showCameraSheet(context);
                  },
                ),
                _AttachOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showDocumentSheet(context);
                  },
                ),
                _AttachOption(
                  icon: Icons.medical_services,
                  label: 'Report',
                  color: Colors.red,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showMedicalReportSheet(context);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

// ── Gallery sheet ─────────────────────────────────────────────────────────────
const _galleryItems = [
  _GalleryItem(color: Color(0xFF90CAF9), icon: Icons.local_hospital,     label: 'Clinic Visit'),
  _GalleryItem(color: Color(0xFFA5D6A7), icon: Icons.healing,            label: 'X-Ray'),
  _GalleryItem(color: Color(0xFFFFCC80), icon: Icons.medication,         label: 'Prescription'),
  _GalleryItem(color: Color(0xFFCE93D8), icon: Icons.monitor_heart,      label: 'ECG'),
  _GalleryItem(color: Color(0xFFEF9A9A), icon: Icons.bloodtype,          label: 'Blood Test'),
  _GalleryItem(color: Color(0xFF80DEEA), icon: Icons.sick,               label: 'Checkup'),
  _GalleryItem(color: Color(0xFFF48FB1), icon: Icons.spa,                label: 'MRI Scan'),
  _GalleryItem(color: Color(0xFFFFF59D), icon: Icons.science,            label: 'Lab Report'),
  _GalleryItem(color: Color(0xFFB0BEC5), icon: Icons.medical_information,label: 'Ultrasound'),
];

void _showGallerySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, sc) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Gallery',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GridView.builder(
                  controller: sc,
                  padding: const EdgeInsets.all(4),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _galleryItems.length,
                  itemBuilder: (_, i) {
                    final item = _galleryItems[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${item.label} selected'),
                              duration: const Duration(seconds: 2)),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item.icon, size: 36, color: Colors.white),
                            const SizedBox(height: 6),
                            Text(item.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _GalleryItem {
  final Color color;
  final IconData icon;
  final String label;
  const _GalleryItem(
      {required this.color, required this.icon, required this.label});
}

// ── Camera sheet ──────────────────────────────────────────────────────────────
void _showCameraSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Spacer(),
                  const Text('Camera',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.flash_off, color: Colors.white),
                ],
              ),
            ),
            // Viewfinder mock
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Simulated scene
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline,
                            size: 80, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text('Point camera at subject',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 13)),
                      ],
                    ),
                    // Focus box
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white54, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    // Grid overlay
                    Positioned.fill(
                      child: CustomPaint(painter: _GridPainter()),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom controls
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Last capture thumbnail
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF90CAF9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.local_hospital,
                        color: Colors.white, size: 24),
                  ),
                  // Shutter
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Photo captured (mock)'),
                            duration: Duration(seconds: 2)),
                      );
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                    ),
                  ),
                  // Flip
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.flip_camera_ios,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 0.5;
    canvas.drawLine(
        Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0),
        Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3),
        Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Document sheet ────────────────────────────────────────────────────────────
const _mockDocuments = [
  _DocItem(
      name: 'Discharge Summary.pdf',
      size: '1.2 MB',
      date: 'Feb 20, 2026',
      color: Color(0xFFE53935),
      icon: Icons.picture_as_pdf),
  _DocItem(
      name: 'Blood Test Results.pdf',
      size: '845 KB',
      date: 'Feb 14, 2026',
      color: Color(0xFFE53935),
      icon: Icons.picture_as_pdf),
  _DocItem(
      name: 'Prescription_Feb.docx',
      size: '320 KB',
      date: 'Feb 10, 2026',
      color: Color(0xFF1565C0),
      icon: Icons.description),
  _DocItem(
      name: 'Insurance_Card.png',
      size: '512 KB',
      date: 'Jan 28, 2026',
      color: Color(0xFF2E7D32),
      icon: Icons.image),
  _DocItem(
      name: 'MRI_Report_Jan.pdf',
      size: '2.4 MB',
      date: 'Jan 15, 2026',
      color: Color(0xFFE53935),
      icon: Icons.picture_as_pdf),
  _DocItem(
      name: 'Allergy_Notes.txt',
      size: '18 KB',
      date: 'Jan 5, 2026',
      color: Color(0xFF6D4C41),
      icon: Icons.text_snippet),
];

void _showDocumentSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, sc) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Documents',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: sc,
                  itemCount: _mockDocuments.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, indent: 72, color: Colors.grey.shade200),
                  itemBuilder: (_, i) {
                    final doc = _mockDocuments[i];
                    return ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: doc.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(doc.icon, color: doc.color, size: 24),
                      ),
                      title: Text(doc.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: Text('${doc.size}  •  ${doc.date}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right,
                          color: Colors.grey),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${doc.name} selected'),
                              duration: const Duration(seconds: 2)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _DocItem {
  final String name;
  final String size;
  final String date;
  final Color color;
  final IconData icon;
  const _DocItem(
      {required this.name,
      required this.size,
      required this.date,
      required this.color,
      required this.icon});
}

// ── Medical Report sheet ──────────────────────────────────────────────────────
const _mockReports = [
  _ReportItem(
      title: 'Complete Blood Count (CBC)',
      lab: 'City Diagnostics Lab',
      date: 'Feb 22, 2026',
      status: 'Normal',
      statusColor: Color(0xFF22C55E),
      icon: Icons.bloodtype),
  _ReportItem(
      title: 'MRI Brain Scan',
      lab: 'Apollo Imaging Centre',
      date: 'Feb 12, 2026',
      status: 'Review',
      statusColor: Color(0xFFF59E0B),
      icon: Icons.monitor_heart),
  _ReportItem(
      title: 'Lipid Profile',
      lab: 'HealthFirst Lab',
      date: 'Feb 5, 2026',
      status: 'Abnormal',
      statusColor: Color(0xFFEF4444),
      icon: Icons.science),
  _ReportItem(
      title: 'Chest X-Ray',
      lab: 'City Diagnostics Lab',
      date: 'Jan 30, 2026',
      status: 'Normal',
      statusColor: Color(0xFF22C55E),
      icon: Icons.medical_information),
  _ReportItem(
      title: 'Urine Routine',
      lab: 'MedLab Services',
      date: 'Jan 18, 2026',
      status: 'Normal',
      statusColor: Color(0xFF22C55E),
      icon: Icons.water_drop),
  _ReportItem(
      title: 'Thyroid Function Test',
      lab: 'HealthFirst Lab',
      date: 'Jan 8, 2026',
      status: 'Review',
      statusColor: Color(0xFFF59E0B),
      icon: Icons.biotech),
];

void _showMedicalReportSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (_, sc) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Text('Medical Reports',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel')),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: sc,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _mockReports.length,
                  separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 72,
                      color: Colors.grey.shade200),
                  itemBuilder: (_, i) {
                    final r = _mockReports[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            r.statusColor.withValues(alpha: 0.12),
                        child: Icon(r.icon, color: r.statusColor, size: 22),
                      ),
                      title: Text(r.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text('${r.lab}  •  ${r.date}',
                          style: const TextStyle(fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: r.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(r.status,
                            style: TextStyle(
                                fontSize: 11,
                                color: r.statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${r.title} selected'),
                              duration: const Duration(seconds: 2)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _ReportItem {
  final String title;
  final String lab;
  final String date;
  final String status;
  final Color statusColor;
  final IconData icon;
  const _ReportItem(
      {required this.title,
      required this.lab,
      required this.date,
      required this.status,
      required this.statusColor,
      required this.icon});
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

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
            onPressed: () => _showCallSheet(context,
                isVideo: true, name: widget.doctorName),
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => _showCallSheet(context,
                isVideo: false, name: widget.doctorName),
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
                    onPressed: () => _showAttachmentSheet(context),
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
