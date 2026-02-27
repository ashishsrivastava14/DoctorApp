import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../mock_data/mock_doctors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReport = 'Appointments';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Type Selector
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'Appointments',
                  'Revenue',
                  'Doctors',
                  'Patients'
                ]
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(r),
                            selected: _selectedReport == r,
                            selectedColor: AppTheme.primaryBlue
                                .withValues(alpha: 0.15),
                            onSelected: (_) =>
                                setState(() => _selectedReport = r),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Appointment Trends Chart
            const Text('Monthly Trends',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
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
                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan','Feb','Mar','Apr','May','Jun',
                                'Jul','Aug','Sep','Oct','Nov','Dec'
                              ];
                              if (value.toInt() < months.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(months[value.toInt()],
                                      style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) =>
                                Text('${value.toInt()}',
                                    style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 11,
                      minY: 0,
                      maxY: 50,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 22), FlSpot(1, 28), FlSpot(2, 25),
                            FlSpot(3, 32), FlSpot(4, 30), FlSpot(5, 38),
                            FlSpot(6, 35), FlSpot(7, 40), FlSpot(8, 42),
                            FlSpot(9, 38), FlSpot(10, 45), FlSpot(11, 48),
                          ],
                          isCurved: true,
                          color: AppTheme.primaryBlue,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 15), FlSpot(1, 20), FlSpot(2, 18),
                            FlSpot(3, 22), FlSpot(4, 25), FlSpot(5, 28),
                            FlSpot(6, 24), FlSpot(7, 30), FlSpot(8, 32),
                            FlSpot(9, 28), FlSpot(10, 35), FlSpot(11, 38),
                          ],
                          isCurved: true,
                          color: AppTheme.successGreen,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.successGreen
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ChartLegend(color: AppTheme.primaryBlue, label: 'Total'),
                const SizedBox(width: 20),
                _ChartLegend(
                    color: AppTheme.successGreen, label: 'Completed'),
              ],
            ),
            const SizedBox(height: 20),

            // Top Doctors
            const Text('Top Performing Doctors',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 60,
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final names = mockDoctors
                                  .take(5)
                                  .map((d) =>
                                      d.name.split(' ').last)
                                  .toList();
                              if (value.toInt() < names.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(names[value.toInt()],
                                      style: const TextStyle(fontSize: 9)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) =>
                                Text('${value.toInt()}',
                                    style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 15,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.shade200,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: List.generate(5, (i) {
                        final values = [52, 45, 38, 35, 30];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: values[i].toDouble(),
                              color: AppTheme.primaryBlue,
                              width: 24,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary Stats
            const Text('Summary Statistics',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatRow(
                        label: 'Average Wait Time',
                        value: '12 min'),
                    _StatRow(
                        label: 'Patient Satisfaction',
                        value: '4.6/5.0'),
                    _StatRow(
                        label: 'Appointment Completion Rate',
                        value: '87%'),
                    _StatRow(
                        label: 'Online Consultations',
                        value: '34%'),
                    _StatRow(
                        label: 'Repeat Patients',
                        value: '62%'),
                    _StatRow(
                        label: 'Average Revenue/Doctor',
                        value: '\$2,450'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
