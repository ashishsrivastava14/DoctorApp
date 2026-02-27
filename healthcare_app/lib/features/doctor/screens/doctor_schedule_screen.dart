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
                          onTap: () {
                            if (slot.status == 'available') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Slot ${slot.time} blocked')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule settings opened')),
          );
        },
        icon: const Icon(Icons.settings),
        label: const Text('Manage'),
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
  final String status;
  final String patientName;
  const _ScheduleSlot(
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
