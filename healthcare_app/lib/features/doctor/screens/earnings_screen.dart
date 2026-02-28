import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_billing.dart';
import '../../../models/billing_model.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'This Month';

  // Using the current date from app context (Feb 28, 2026)
  final DateTime _now = DateTime(2026, 2, 28);

  // ── Chart helpers ────────────────────────────────────────────────────────────

  List<String> _getLabels() {
    switch (_period) {
      case 'This Week':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'This Month':
        return ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
      default: // This Year
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }
  }

  List<BarChartGroupData> _getBarGroups() {
    switch (_period) {
      case 'This Week':
        return _buildWeekGroups();
      case 'This Month':
        return _buildMonthGroups();
      default:
        return _buildYearGroups();
    }
  }

  List<BarChartGroupData> _buildWeekGroups() {
    // Monday of the current week
    final monday = _now.subtract(Duration(days: _now.weekday - 1));
    final buckets = List<double>.filled(7, 0);
    for (final bill in mockBillings) {
      if (bill.status != 'Paid') continue;
      final diff = bill.date.difference(monday).inDays;
      if (diff >= 0 && diff < 7) buckets[diff] += bill.amount;
    }
    return List.generate(7, (i) => _makeBarGroup(i, buckets[i]));
  }

  List<BarChartGroupData> _buildMonthGroups() {
    final buckets = List<double>.filled(4, 0);
    for (final bill in mockBillings) {
      if (bill.status != 'Paid') continue;
      if (bill.date.year != _now.year || bill.date.month != _now.month) continue;
      final weekIndex = ((bill.date.day - 1) ~/ 7).clamp(0, 3);
      buckets[weekIndex] += bill.amount;
    }
    return List.generate(4, (i) => _makeBarGroup(i, buckets[i]));
  }

  List<BarChartGroupData> _buildYearGroups() {
    final buckets = List<double>.filled(12, 0);
    for (final bill in mockBillings) {
      if (bill.status != 'Paid') continue;
      if (bill.date.year != _now.year) continue;
      buckets[bill.date.month - 1] += bill.amount;
    }
    return List.generate(12, (i) => _makeBarGroup(i, buckets[i]));
  }

  // ── Data helpers ─────────────────────────────────────────────────────────────

  double _getThisMonthEarnings(List<BillingModel> paid) {
    return paid
        .where((b) => b.date.year == _now.year && b.date.month == _now.month)
        .fold<double>(0, (sum, b) => sum + b.amount);
  }

  List<BillingModel> _getFilteredTransactions() {
    switch (_period) {
      case 'This Week':
        final monday = _now.subtract(Duration(days: _now.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return mockBillings
            .where((b) =>
                !b.date.isBefore(monday) && !b.date.isAfter(sunday))
            .toList();
      case 'This Month':
        return mockBillings
            .where((b) =>
                b.date.year == _now.year && b.date.month == _now.month)
            .toList();
      default: // This Year
        return mockBillings
            .where((b) => b.date.year == _now.year)
            .toList();
    }
  }

  // ── Status helpers ───────────────────────────────────────────────────────────

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return AppTheme.successGreen;
      case 'Overdue':
        return AppTheme.errorRed;
      default:
        return AppTheme.warningAmber;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Overdue':
        return Icons.error;
      default:
        return Icons.pending;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final paidBillings =
        mockBillings.where((b) => b.status == 'Paid').toList();
    final totalEarnings =
        paidBillings.fold<double>(0, (sum, b) => sum + b.amount);
    final pendingAmount = mockBillings
        .where((b) => b.status == 'Pending')
        .fold<double>(0, (sum, b) => sum + b.amount);
    final thisMonthEarnings = _getThisMonthEarnings(paidBillings);

    final barGroups = _getBarGroups();
    final labels = _getLabels();
    final rawMax = barGroups.isEmpty
        ? 0.0
        : barGroups
            .map((g) => g.barRods.first.toY)
            .reduce((a, b) => a > b ? a : b);
    final maxY = rawMax > 0 ? (rawMax * 1.25).ceilToDouble() : 500.0;
    final interval = (maxY / 4).ceilToDouble();

    final filteredTransactions = _getFilteredTransactions();
    final barWidth = _period == 'This Year' ? 14.0 : 20.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Summary Card ──────────────────────────────────────────────────
            Card(
              color: AppTheme.primaryBlue,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Earnings',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _EarningsStat(
                            label: 'This Month',
                            value:
                                '\$${thisMonthEarnings.toStringAsFixed(0)}',
                            icon: Icons.calendar_today),
                        Container(
                            width: 1, height: 30, color: Colors.white24),
                        _EarningsStat(
                            label: 'Pending',
                            value:
                                '\$${pendingAmount.toStringAsFixed(0)}',
                            icon: Icons.pending_actions),
                        Container(
                            width: 1, height: 30, color: Colors.white24),
                        _EarningsStat(
                            label: 'Consultations',
                            value: '${paidBillings.length}',
                            icon: Icons.people),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Period Filter ─────────────────────────────────────────────────
            Row(
              children: [
                const Text('Earnings Trend',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                DropdownButton<String>(
                  value: _period,
                  underline: const SizedBox(),
                  isDense: true,
                  items: ['This Week', 'This Month', 'This Year']
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _period = v!),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Bar Chart ─────────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem:
                              (group, groupIdx, rod, rodIdx) {
                            return BarTooltipItem(
                              '\$${rod.toY.toInt()}',
                              const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < labels.length) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 6),
                                  child: Text(labels[idx],
                                      style: const TextStyle(
                                          fontSize: 10)),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 44,
                            getTitlesWidget: (value, meta) {
                              return Text('\$${value.toInt()}',
                                  style:
                                      const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: barGroups,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: interval,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Transactions ──────────────────────────────────────────────────
            Row(
              children: [
                const Text('Transactions',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('($_period)',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            if (filteredTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                    child: Text('No transactions for this period')),
              )
            else
              ...filteredTransactions.map((bill) {
                final color = _statusColor(bill.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(_statusIcon(bill.status),
                          color: color, size: 20),
                    ),
                    title: Text(bill.patientName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      '${bill.description} • ${DateFormat('MMM dd').format(bill.date)}',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${bill.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: color),
                        ),
                        Text(bill.status,
                            style:
                                TextStyle(fontSize: 10, color: color)),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    final barWidth = _period == 'This Year' ? 14.0 : 20.0;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryBlue,
          width: barWidth,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _EarningsStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _EarningsStat(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}
