import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class DoctorScheduleScreen extends StatefulWidget {
  const DoctorScheduleScreen({super.key});

  @override
  State<DoctorScheduleScreen> createState() => _DoctorScheduleScreenState();
}

class _DoctorScheduleScreenState extends State<DoctorScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Mock schedule data
  final Map<String, List<_ScheduleSlot>> _scheduleData = {};

  @override
  void initState() {
    super.initState();
    _generateMockSchedule();
  }

  void _generateMockSchedule() {
    final today = DateTime.now();
    for (int d = -7; d < 30; d++) {
      final date = today.add(Duration(days: d));
      if (date.weekday == DateTime.sunday) continue;
      final key = DateFormat('yyyy-MM-dd').format(date);
      final slots = <_ScheduleSlot>[];
      for (int i = 0; i < AppConstants.timeSlots.length; i++) {
        final status = d < 0
            ? 'completed'
            : (i % 4 == 0
                ? 'booked'
                : (i % 3 == 0 ? 'blocked' : 'available'));
        String patientName = '';
        if (status == 'booked' || status == 'completed') {
          final names = [
            'John Smith',
            'Jane Doe',
            'Robert Johnson',
            'Emily Chen',
            'Michael Brown'
          ];
          patientName = names[i % names.length];
        }
        slots.add(_ScheduleSlot(
          time: AppConstants.timeSlots[i],
          status: status,
          patientName: patientName,
        ));
      }
      _scheduleData[key] = slots;
    }
  }

  List<_ScheduleSlot> _getSlotsForDay(DateTime day) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return _scheduleData[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final slots = _getSlotsForDay(_selectedDay);
    final bookedCount = slots.where((s) => s.status == 'booked').length;
    final availableCount =
        slots.where((s) => s.status == 'available').length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Schedule')),
      body: Column(
        children: [
          // Calendar
          Card(
            margin: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 30)),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              calendarFormat: _calendarFormat,
              onFormatChanged: (f) =>
                  setState(() => _calendarFormat = f),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle:
                    const TextStyle(color: AppTheme.errorRed),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
              eventLoader: (day) => _getSlotsForDay(day)
                  .where((s) => s.status == 'booked')
                  .toList(),
            ),
          ),

          // Day Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  DateFormat('EEEE, MMM dd').format(_selectedDay),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                _CountBadge(
                    count: bookedCount,
                    label: 'Booked',
                    color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                _CountBadge(
                    count: availableCount,
                    label: 'Free',
                    color: AppTheme.successGreen),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Time Slots
          Expanded(
            child: slots.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No schedule for this day',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: slots.length,
                    itemBuilder: (ctx, idx) {
                      final slot = slots[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 6),
                        child: ListTile(
                          leading: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _slotColor(slot.status),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          title: Text(slot.time,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          subtitle: slot.patientName.isNotEmpty
                              ? Text(slot.patientName,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary))
                              : Text(
                                  slot.status == 'blocked'
                                      ? 'Blocked'
                                      : 'Available',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _slotColor(slot.status)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _slotLabel(slot.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _slotColor(slot.status),
                              ),
                            ),
                          ),
                          onTap: () => _handleSlotTap(ctx, slot),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showManageSheet(context),
        icon: const Icon(Icons.settings),
        label: const Text('Manage'),
      ),
    );
  }

  void _handleSlotTap(BuildContext ctx, _ScheduleSlot slot) {
    if (slot.status == 'booked' || slot.status == 'completed') {
      showDialog(
        context: ctx,
        builder: (dialogCtx) => AlertDialog(
          title: Text(slot.status == 'booked' ? 'Booked Appointment' : 'Completed Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(slot.time, style: const TextStyle(fontSize: 14)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(slot.patientName, style: const TextStyle(fontSize: 14)),
              ]),
            ],
          ),
          actions: [
            if (slot.status == 'booked')
              TextButton(
                onPressed: () {
                  setState(() => slot.status = 'blocked');
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Slot ${slot.time} cancelled and blocked')),
                  );
                },
                child: const Text('Cancel Slot', style: TextStyle(color: AppTheme.errorRed)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    // Toggle available ↔ blocked
    if (slot.status == 'available') {
      setState(() => slot.status = 'blocked');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Slot ${slot.time} blocked'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => slot.status = 'available'),
          ),
        ),
      );
    } else if (slot.status == 'blocked') {
      setState(() => slot.status = 'available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot ${slot.time} unblocked')),
      );
    }
  }

  void _showManageSheet(BuildContext ctx) {
    final key = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final slots = _scheduleData[key] ?? [];
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM dd').format(_selectedDay),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Manage all slots for this day',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const Divider(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                child: const Icon(Icons.block, color: AppTheme.errorRed, size: 20),
              ),
              title: const Text('Block All Available Slots'),
              subtitle: const Text('Mark all open slots as unavailable'),
              onTap: () {
                setState(() {
                  for (final s in slots) {
                    if (s.status == 'available') s.status = 'blocked';
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All available slots blocked')),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.successGreen.withValues(alpha: 0.1),
                child: const Icon(Icons.check_circle_outline,
                    color: AppTheme.successGreen, size: 20),
              ),
              title: const Text('Unblock All Blocked Slots'),
              subtitle: const Text('Re-open all blocked slots'),
              onTap: () {
                setState(() {
                  for (final s in slots) {
                    if (s.status == 'blocked') s.status = 'available';
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All blocked slots unblocked')),
                );
              },
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: const Icon(Icons.event_busy,
                    color: AppTheme.primaryBlue, size: 20),
              ),
              title: const Text('Mark Day as Off'),
              subtitle: const Text('Block all slots for the entire day'),
              onTap: () {
                setState(() {
                  for (final s in slots) {
                    if (s.status != 'booked' && s.status != 'completed') {
                      s.status = 'blocked';
                    }
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Day marked as off')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _slotColor(String status) {
    switch (status) {
      case 'booked':
        return AppTheme.primaryBlue;
      case 'completed':
        return AppTheme.successGreen;
      case 'blocked':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  String _slotLabel(String status) {
    switch (status) {
      case 'booked':
        return 'Booked';
      case 'completed':
        return 'Done';
      case 'blocked':
        return 'Blocked';
      default:
        return 'Open';
    }
  }
}

class _ScheduleSlot {
  final String time;
  String status;
  final String patientName;
  _ScheduleSlot(
      {required this.time,
      required this.status,
      this.patientName = ''});
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _CountBadge(
      {required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$count $label',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
