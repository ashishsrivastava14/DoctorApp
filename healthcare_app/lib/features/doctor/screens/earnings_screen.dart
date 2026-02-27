import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_billing.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _period = 'This Month';

  @override
  Widget build(BuildContext context) {
    final earnings = mockBillings
        .where((b) => b.status == 'Paid')
        .toList();

    final totalEarnings =
        earnings.fold<double>(0, (sum, b) => sum + b.amount);
    final pendingAmount = mockBillings
        .where((b) => b.status == 'Pending')
        .fold<double>(0, (sum, b) => sum + b.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Summary Card
            Card(
              color: AppTheme.primaryBlue,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Earnings',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
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
                                '\$${(totalEarnings * 0.3).toStringAsFixed(0)}',
                            icon: Icons.calendar_today),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white24),
                        _EarningsStat(
                            label: 'Pending',
                            value:
                                '\$${pendingAmount.toStringAsFixed(0)}',
                            icon: Icons.pending_actions),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white24),
                        _EarningsStat(
                            label: 'Consultations',
                            value: '${earnings.length}',
                            icon: Icons.people),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Period Filter
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

            // Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 1000,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIdx, rod, rodIdx) {
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
                              final labels = [
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                                'Sun'
                              ];
                              if (value.toInt() < labels.length) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: Text(labels[value.toInt()],
                                      style: const TextStyle(
                                          fontSize: 11)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text('\$${value.toInt()}',
                                  style: const TextStyle(
                                      fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        _makeBarGroup(0, 650),
                        _makeBarGroup(1, 820),
                        _makeBarGroup(2, 450),
                        _makeBarGroup(3, 780),
                        _makeBarGroup(4, 900),
                        _makeBarGroup(5, 350),
                        _makeBarGroup(6, 0),
                      ],
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 250,
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

            // Recent Transactions
            const Text('Recent Transactions',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...mockBillings.take(10).map((bill) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bill.status == 'Paid'
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.warningAmber.withValues(alpha: 0.1),
                    child: Icon(
                      bill.status == 'Paid'
                          ? Icons.check_circle
                          : Icons.pending,
                      color: bill.status == 'Paid'
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                      size: 20,
                    ),
                  ),
                  title: Text(bill.patientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    '${bill.description} • ${DateFormat('MMM dd').format(bill.date)}',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  trailing: Text(
                    '\$${bill.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: bill.status == 'Paid'
                          ? AppTheme.successGreen
                          : AppTheme.warningAmber,
                    ),
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
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppTheme.primaryBlue,
          width: 20,
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
