import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../mock_data/mock_billing.dart';
import '../../../mock_data/mock_doctors.dart';
import '../../../mock_data/mock_patients.dart';
import '../../../models/patient_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReport = 'Appointments';
  String _period = 'This Year';

  // Reference date for the demo
  final _now = DateTime(2026, 2, 28);

  bool _inPeriod(DateTime date) {
    switch (_period) {
      case 'This Month':
        return date.year == _now.year && date.month == _now.month;
      case 'Last 3 Months':
        final cutoff = DateTime(_now.year, _now.month - 2, 1);
        return !date.isBefore(cutoff);
      default: // This Year
        return date.year == _now.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Report',
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSelectors(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Selectors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildSelectors() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['Appointments', 'Revenue', 'Doctors', 'Patients']
                  .map((r) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(r, style: const TextStyle(fontSize: 12)),
                          selected: _selectedReport == r,
                          selectedColor:
                              AppTheme.primaryBlue.withValues(alpha: 0.15),
                          onSelected: (_) =>
                              setState(() => _selectedReport = r),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['This Month', 'Last 3 Months', 'This Year']
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p, style: const TextStyle(fontSize: 11)),
                          selected: _period == p,
                          selectedColor:
                              AppTheme.successGreen.withValues(alpha: 0.15),
                          onSelected: (_) => setState(() => _period = p),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // â”€â”€ Body router â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildBody() {
    switch (_selectedReport) {
      case 'Revenue':
        return _buildRevenueReport();
      case 'Doctors':
        return _buildDoctorsReport();
      case 'Patients':
        return _buildPatientsReport();
      default:
        return _buildAppointmentsReport();
    }
  }

  // â”€â”€ APPOINTMENTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildAppointmentsReport() {
    final filtered =
        mockAppointments.where((a) => _inPeriod(a.date)).toList();
    final total = filtered.length;
    final confirmed =
        filtered.where((a) => a.status == 'Confirmed').length;
    final completed =
        filtered.where((a) => a.status == 'Completed').length;
    final pending = filtered.where((a) => a.status == 'Pending').length;
    final cancelled =
        filtered.where((a) => a.status == 'Cancelled').length;
    final online = filtered.where((a) => a.type == 'Online').length;
    final inPerson = total - online;

    final monthlyCounts = List.generate(
        12,
        (m) =>
            filtered.where((a) => a.date.month == m + 1).length);
    final monthlyCompleted = List.generate(
        12,
        (m) =>
            filtered
                .where((a) =>
                    a.date.month == m + 1 && a.status == 'Completed')
                .length);
    final maxY =
        (_maxInt(monthlyCounts) + 2).toDouble().clamp(5.0, double.infinity);

    final specMap = <String, int>{};
    for (final a in filtered) {
      specMap[a.doctorSpecialty] = (specMap[a.doctorSpecialty] ?? 0) + 1;
    }
    final topSpec = specMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(children: [
          _MiniStatCard(
              label: 'Total', value: '$total', color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Confirmed',
              value: '$confirmed',
              color: AppTheme.successGreen),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Done',
              value: '$completed',
              color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Pending',
              value: '$pending',
              color: AppTheme.warningAmber),
        ]),
        const SizedBox(height: 20),
        const _SectionHeader('Monthly Appointment Trends'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          const months = [
                            'J', 'F', 'M', 'A', 'M', 'J',
                            'J', 'A', 'S', 'O', 'N', 'D'
                          ];
                          final i = v.toInt();
                          return i >= 0 && i < 12
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(months[i],
                                      style:
                                          const TextStyle(fontSize: 10)))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, m) => Text('${v.toInt()}',
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(12,
                          (i) => FlSpot(i.toDouble(), monthlyCounts[i].toDouble())),
                      isCurved: true,
                      color: AppTheme.primaryBlue,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppTheme.primaryBlue.withValues(alpha: 0.08)),
                    ),
                    LineChartBarData(
                      spots: List.generate(12,
                          (i) => FlSpot(i.toDouble(), monthlyCompleted[i].toDouble())),
                      isCurved: true,
                      color: AppTheme.successGreen,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true,
                          color:
                              AppTheme.successGreen.withValues(alpha: 0.08)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ChartLegend(color: AppTheme.primaryBlue, label: 'Total'),
          const SizedBox(width: 20),
          _ChartLegend(color: AppTheme.successGreen, label: 'Completed'),
        ]),
        const SizedBox(height: 20),
        const _SectionHeader('Appointment Type Breakdown'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _TypeBar(
                  label: 'Online',
                  count: online,
                  total: total > 0 ? total : 1,
                  color: AppTheme.primaryBlue),
              const SizedBox(height: 12),
              _TypeBar(
                  label: 'In Person',
                  count: inPerson,
                  total: total > 0 ? total : 1,
                  color: AppTheme.successGreen),
              if (cancelled > 0) ...[
                const SizedBox(height: 12),
                _TypeBar(
                    label: 'Cancelled',
                    count: cancelled,
                    total: total > 0 ? total : 1,
                    color: AppTheme.errorRed),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Top Specialties'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: topSpec.isEmpty
                ? _emptyData()
                : Column(
                    children: topSpec
                        .take(6)
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TypeBar(
                                  label: e.key,
                                  count: e.value,
                                  total: total > 0 ? total : 1,
                                  color: AppTheme.primaryBlue),
                            ))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Summary Statistics'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _StatRow(label: 'Total Appointments', value: '$total'),
              _StatRow(label: 'Confirmed', value: '$confirmed'),
              _StatRow(label: 'Completed', value: '$completed'),
              _StatRow(label: 'Pending', value: '$pending'),
              _StatRow(label: 'Cancelled', value: '$cancelled'),
              _StatRow(
                  label: 'Completion Rate',
                  value: total > 0
                      ? '${(completed / total * 100).toStringAsFixed(1)}%'
                      : '-'),
              _StatRow(
                  label: 'Online Rate',
                  value: total > 0
                      ? '${(online / total * 100).toStringAsFixed(1)}%'
                      : '-'),
            ]),
          ),
        ),
      ],
    );
  }

  // â”€â”€ REVENUE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildRevenueReport() {
    final filtered =
        mockBillings.where((b) => _inPeriod(b.date)).toList();
    final totalRev =
        filtered.fold<double>(0, (s, b) => s + b.amount);
    final paidRev = filtered
        .where((b) => b.status == 'Paid')
        .fold<double>(0, (s, b) => s + b.amount);
    final pendingRev = filtered
        .where((b) => b.status == 'Pending')
        .fold<double>(0, (s, b) => s + b.amount);
    final overdueRev = filtered
        .where((b) => b.status == 'Overdue')
        .fold<double>(0, (s, b) => s + b.amount);

    final monthlyRev = List.generate(
        12,
        (m) => filtered
            .where((b) => b.date.month == m + 1)
            .fold<double>(0, (s, b) => s + b.amount));
    final maxMonthly =
        monthlyRev.reduce((a, b) => a > b ? a : b).clamp(500.0, double.infinity);

    final payMethods = <String, double>{};
    for (final b in filtered) {
      payMethods[b.paymentMethod] =
          (payMethods[b.paymentMethod] ?? 0) + b.amount;
    }
    final payList = payMethods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final docRev = <String, double>{};
    for (final b in filtered) {
      docRev[b.doctorName] = (docRev[b.doctorName] ?? 0) + b.amount;
    }
    final topDocs = docRev.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(children: [
          _MiniStatCard(
              label: 'Total',
              value: '\$${totalRev.toStringAsFixed(0)}',
              color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Paid',
              value: '\$${paidRev.toStringAsFixed(0)}',
              color: AppTheme.successGreen),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Pending',
              value: '\$${pendingRev.toStringAsFixed(0)}',
              color: AppTheme.warningAmber),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Overdue',
              value: '\$${overdueRev.toStringAsFixed(0)}',
              color: AppTheme.errorRed),
        ]),
        const SizedBox(height: 20),
        const _SectionHeader('Monthly Revenue'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxMonthly + 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) =>
                          BarTooltipItem(
                              '\$${rod.toY.toStringAsFixed(0)}',
                              const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          const months = [
                            'J', 'F', 'M', 'A', 'M', 'J',
                            'J', 'A', 'S', 'O', 'N', 'D'
                          ];
                          final i = v.toInt();
                          return i >= 0 && i < 12
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(months[i],
                                      style:
                                          const TextStyle(fontSize: 10)))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => FittedBox(
                          child: Text('\$${v.toInt()}',
                              style: const TextStyle(fontSize: 9))),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  barGroups: List.generate(
                      12,
                      (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: monthlyRev[i],
                                color: monthlyRev[i] > 0
                                    ? AppTheme.primaryBlue
                                    : Colors.grey.shade200,
                                width: 14,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              )
                            ],
                          )),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Payment Method Breakdown'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: payList.isEmpty
                ? _emptyData()
                : Column(
                    children: payList
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TypeBar(
                                label: e.key,
                                count: e.value.toInt(),
                                total: totalRev > 0
                                    ? totalRev.toInt()
                                    : 1,
                                color: AppTheme.primaryBlue,
                                isAmount: true,
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Top Revenue-Generating Doctors'),
        const SizedBox(height: 10),
        Card(
          child: topDocs.isEmpty
              ? _emptyData()
              : Column(
                  children: topDocs
                      .take(5)
                      .map((e) {
                        final pct =
                            totalRev > 0 ? e.value / totalRev : 0.0;
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                            child: const Icon(
                                Icons.medical_services_outlined,
                                size: 16,
                                color: AppTheme.primaryBlue),
                          ),
                          title: Text(e.key,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  '\$${e.value.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.primaryBlue)),
                              Text(
                                  '${(pct * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Revenue Summary'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _StatRow(
                  label: 'Total Revenue',
                  value: '\$${totalRev.toStringAsFixed(2)}'),
              _StatRow(
                  label: 'Collected (Paid)',
                  value: '\$${paidRev.toStringAsFixed(2)}'),
              _StatRow(
                  label: 'Outstanding (Pending)',
                  value: '\$${pendingRev.toStringAsFixed(2)}'),
              _StatRow(
                  label: 'Overdue',
                  value: '\$${overdueRev.toStringAsFixed(2)}'),
              _StatRow(
                  label: 'Collection Rate',
                  value: totalRev > 0
                      ? '${(paidRev / totalRev * 100).toStringAsFixed(1)}%'
                      : '-'),
              _StatRow(
                  label: 'Total Invoices',
                  value: '${filtered.length}'),
            ]),
          ),
        ),
      ],
    );
  }

  // â”€â”€ DOCTORS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildDoctorsReport() {
    final doctors = mockDoctors;
    final total = doctors.length;
    final available = doctors.where((d) => d.isAvailable).length;
    final avgRating =
        doctors.fold<double>(0, (s, d) => s + d.rating) / total;
    final totalPatients =
        doctors.fold<int>(0, (s, d) => s + d.patientCount);

    final sorted = doctors.toList()
      ..sort((a, b) => b.patientCount.compareTo(a.patientCount));
    final top5 = sorted.take(5).toList();
    final maxPts =
        top5.first.patientCount.toDouble().clamp(100.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(children: [
          _MiniStatCard(
              label: 'Total', value: '$total', color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Available',
              value: '$available',
              color: AppTheme.successGreen),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Avg â˜…',
              value: avgRating.toStringAsFixed(1),
              color: Colors.amber),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Patients',
              value: '$totalPatients',
              color: AppTheme.primaryBlue),
        ]),
        const SizedBox(height: 20),
        const _SectionHeader('Top Doctors by Patient Count'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxPts + 200,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) =>
                          BarTooltipItem(
                              '${rod.toY.toInt()} pts',
                              const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final i = v.toInt();
                          return i >= 0 && i < top5.length
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                      top5[i].name.split(' ').last,
                                      style:
                                          const TextStyle(fontSize: 9)))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(fontSize: 9)),
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  barGroups: List.generate(
                      top5.length,
                      (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: top5[i].patientCount.toDouble(),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1D4ED8),
                                    Color(0xFF60A5FA)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 28,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              )
                            ],
                          )),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Doctor Performance Table'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: sorted
                .map((doc) => ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: doc.isAvailable
                            ? AppTheme.successGreen.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        child: Icon(Icons.person,
                            size: 18,
                            color: doc.isAvailable
                                ? AppTheme.successGreen
                                : Colors.grey),
                      ),
                      title: Text(doc.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          '${doc.specialty}  â€¢  ${doc.experienceYears} yrs',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.star,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 3),
                            Text('${doc.rating}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ]),
                          Text('${doc.patientCount} pts',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Summary Statistics'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _StatRow(label: 'Total Doctors', value: '$total'),
              _StatRow(label: 'Available Now', value: '$available'),
              _StatRow(
                  label: 'Unavailable',
                  value: '${total - available}'),
              _StatRow(
                  label: 'Average Rating',
                  value: avgRating.toStringAsFixed(2)),
              _StatRow(
                  label: 'Total Patients Served',
                  value: '$totalPatients'),
              _StatRow(
                  label: 'Avg Patients / Doctor',
                  value:
                      '${(totalPatients / total).round()}'),
            ]),
          ),
        ),
      ],
    );
  }

  // â”€â”€ PATIENTS â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _buildPatientsReport() {
    final patients = mockPatients;
    final total = patients.length;
    final male =
        patients.where((p) => p.gender == 'Male').length;
    final female =
        patients.where((p) => p.gender == 'Female').length;

    int age0to20 = 0, age21to35 = 0, age36to50 = 0, age51plus = 0;
    int ageSum = 0;
    for (final p in patients) {
      final age = _now.year - p.dateOfBirth.year;
      ageSum += age;
      if (age <= 20) {
        age0to20++;
      } else if (age <= 35) age21to35++;
      else if (age <= 50) age36to50++;
      else age51plus++;
    }
    final avgAge = (ageSum / total).round();
    final ageGroups = [age0to20, age21to35, age36to50, age51plus];
    const ageLabels = ['â‰¤20', '21-35', '36-50', '51+'];
    final maxAge = ageGroups
        .reduce((a, b) => a > b ? a : b)
        .toDouble()
        .clamp(3.0, double.infinity);

    final bloodMap = <String, int>{};
    for (final p in patients) {
      bloodMap[p.bloodGroup] = (bloodMap[p.bloodGroup] ?? 0) + 1;
    }
    final bloodList = bloodMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final withAllergies =
        patients.where((p) => p.allergies.isNotEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(children: [
          _MiniStatCard(
              label: 'Total', value: '$total', color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Male',
              value: '$male',
              color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Female',
              value: '$female',
              color: const Color(0xFFF472B6)),
          const SizedBox(width: 8),
          _MiniStatCard(
              label: 'Avg Age',
              value: '$avgAge',
              color: AppTheme.warningAmber),
        ]),
        const SizedBox(height: 20),
        const _SectionHeader('Age Group Distribution'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAge + 1,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) =>
                          BarTooltipItem(
                              '${rod.toY.toInt()} patients',
                              const TextStyle(
                                  color: Colors.white, fontSize: 12)),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          final i = v.toInt();
                          return i >= 0 && i < 4
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(ageLabels[i],
                                      style:
                                          const TextStyle(fontSize: 11)))
                              : const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) => Text('${v.toInt()}',
                          style: const TextStyle(fontSize: 10)),
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (v) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  barGroups: List.generate(
                      4,
                      (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: ageGroups[i].toDouble(),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2563EB),
                                    Color(0xFF60A5FA)
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 40,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              )
                            ],
                          )),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Gender Distribution'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _TypeBar(
                  label: 'Male',
                  count: male,
                  total: total,
                  color: AppTheme.primaryBlue),
              const SizedBox(height: 12),
              _TypeBar(
                  label: 'Female',
                  count: female,
                  total: total,
                  color: const Color(0xFFF472B6)),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Blood Group Distribution'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: bloodList
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.primaryBlue
                                  .withValues(alpha: 0.2)),
                        ),
                        child: Column(children: [
                          Text(e.key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AppTheme.primaryBlue)),
                          Text(
                              '${e.value} pt${e.value == 1 ? '' : 's'}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        ]),
                      ))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _SectionHeader('Patient Summary'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _StatRow(
                  label: 'Total Registered', value: '$total'),
              _StatRow(
                  label: 'Male',
                  value:
                      '$male (${(male / total * 100).toStringAsFixed(0)}%)'),
              _StatRow(
                  label: 'Female',
                  value:
                      '$female (${(female / total * 100).toStringAsFixed(0)}%)'),
              _StatRow(label: 'Average Age', value: '$avgAge yrs'),
              _StatRow(
                  label: 'With Allergies', value: '$withAllergies'),
              _StatRow(
                  label: 'Most Common Blood Group',
                  value: bloodList.isNotEmpty
                      ? bloodList.first.key
                      : '-'),
            ]),
          ),
        ),
      ],
    );
  }

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  int _maxInt(List<int> list) =>
      list.isEmpty ? 0 : list.reduce((a, b) => a > b ? a : b);

  Widget _emptyData() => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
            child:
                Text('No data for selected period', style: TextStyle(color: Colors.grey))),
      );

  void _exportReport() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Export "$_selectedReport" report ($_period)',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            const Text('Choose format:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ExportOption(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    color: AppTheme.errorRed,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('PDF export started...')));
                    }),
                _ExportOption(
                    icon: Icons.table_chart,
                    label: 'Excel',
                    color: AppTheme.successGreen,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Excel export started...')));
                    }),
                _ExportOption(
                    icon: Icons.code,
                    label: 'CSV',
                    color: AppTheme.warningAmber,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('CSV export started...')));
                    }),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'))
        ],
      ),
    );
  }
}

// â”€â”€ Shared helper widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700));
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final bool isAmount;
  const _TypeBar(
      {required this.label,
      required this.count,
      required this.total,
      required this.color,
      this.isAmount = false});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isAmount ? '\$$count' : '$count (${(pct * 100).toStringAsFixed(0)}%)',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary))),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ExportOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
