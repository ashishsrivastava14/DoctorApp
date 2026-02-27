import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../mock_data/mock_doctors.dart';
import '../../../mock_data/mock_patients.dart';
import '../../../mock_data/mock_appointments.dart';
import '../../../mock_data/mock_billing.dart';
import '../../../mock_data/mock_departments.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final paidRevenue = mockBillings
        .where((b) => b.status == 'Paid')
        .fold<double>(0, (sum, b) => sum + b.amount);

    final confirmedAppts =
        mockAppointments.where((a) => a.status == 'Confirmed').length;
    final pendingAppts =
        mockAppointments.where((a) => a.status == 'Pending').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('5'),
              child: Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/admin/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards Row 1
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.medical_services,
                    value: '${mockDoctors.length}',
                    label: 'Doctors',
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.people,
                    value: '${mockPatients.length}',
                    label: 'Patients',
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    value: '${mockAppointments.length}',
                    label: 'Appointments',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // KPI Cards Row 2
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.attach_money,
                    value: '\$${paidRevenue.toStringAsFixed(0)}',
                    label: 'Revenue',
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.apartment,
                    value: '${mockDepartments.length}',
                    label: 'Departments',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.pending_actions,
                    value: '$pendingAppts',
                    label: 'Pending',
                    color: AppTheme.warningAmber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Appointments Overview (Pie Chart)
            const Text('Appointment Status',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              value: confirmedAppts.toDouble(),
                              color: AppTheme.successGreen,
                              title: '$confirmedAppts',
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              radius: 35,
                            ),
                            PieChartSectionData(
                              value: pendingAppts.toDouble(),
                              color: AppTheme.warningAmber,
                              title: '$pendingAppts',
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              radius: 35,
                            ),
                            PieChartSectionData(
                              value: mockAppointments
                                  .where((a) =>
                                      a.status == 'Completed')
                                  .length
                                  .toDouble(),
                              color: AppTheme.primaryBlue,
                              title:
                                  '${mockAppointments.where((a) => a.status == 'Completed').length}',
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              radius: 35,
                            ),
                            PieChartSectionData(
                              value: mockAppointments
                                  .where((a) =>
                                      a.status == 'Cancelled')
                                  .length
                                  .toDouble(),
                              color: AppTheme.errorRed,
                              title:
                                  '${mockAppointments.where((a) => a.status == 'Cancelled').length}',
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                              radius: 35,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(
                              color: AppTheme.successGreen,
                              label: 'Confirmed'),
                          _LegendItem(
                              color: AppTheme.warningAmber,
                              label: 'Pending'),
                          _LegendItem(
                              color: AppTheme.primaryBlue,
                              label: 'Completed'),
                          _LegendItem(
                              color: AppTheme.errorRed,
                              label: 'Cancelled'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Revenue Chart
            const Text('Revenue Trend',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 2000,
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
                                'Jan', 'Feb', 'Mar', 'Apr',
                                'May', 'Jun'
                              ];
                              if (value.toInt() < months.length) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8),
                                  child: Text(
                                      months[value.toInt()],
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
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                  '\$${(value / 1000).toStringAsFixed(0)}k',
                                  style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: 10000,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 4500),
                            FlSpot(1, 5200),
                            FlSpot(2, 6800),
                            FlSpot(3, 5900),
                            FlSpot(4, 7400),
                            FlSpot(5, 8200),
                          ],
                          isCurved: true,
                          color: AppTheme.primaryBlue,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryBlue
                                .withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Links
            const Text('Quick Actions',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                _AdminQuickLink(
                    icon: Icons.person_add,
                    label: 'Add Doctor',
                    color: AppTheme.primaryBlue,
                    onTap: () => context.go('/admin/doctors')),
                _AdminQuickLink(
                    icon: Icons.apartment,
                    label: 'Departments',
                    color: Colors.purple,
                    onTap: () => context.push('/admin/departments')),
                _AdminQuickLink(
                    icon: Icons.receipt_long,
                    label: 'Billing',
                    color: Colors.orange,
                    onTap: () => context.push('/admin/billing')),
                _AdminQuickLink(
                    icon: Icons.assessment,
                    label: 'Reports',
                    color: Colors.teal,
                    onTap: () => context.push('/admin/reports')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _AdminQuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminQuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  Color get _lighter {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: color.withValues(alpha: 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, _lighter],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
