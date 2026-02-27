import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../mock_data/mock_billing.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    var bills = mockBillings.toList();
    if (_statusFilter != 'All') {
      bills = bills.where((b) => b.status == _statusFilter).toList();
    }
    bills.sort((a, b) => b.date.compareTo(a.date));

    final totalRevenue =
        mockBillings.fold<double>(0, (sum, b) => sum + b.amount);
    final paidTotal = mockBillings
        .where((b) => b.status == 'Paid')
        .fold<double>(0, (sum, b) => sum + b.amount);
    final pendingTotal = mockBillings
        .where((b) => b.status == 'Pending')
        .fold<double>(0, (sum, b) => sum + b.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Billing & Payments')),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _SummaryCard(
                    label: 'Total',
                    value: '\$${totalRevenue.toStringAsFixed(0)}',
                    color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                _SummaryCard(
                    label: 'Paid',
                    value: '\$${paidTotal.toStringAsFixed(0)}',
                    color: AppTheme.successGreen),
                const SizedBox(width: 8),
                _SummaryCard(
                    label: 'Pending',
                    value: '\$${pendingTotal.toStringAsFixed(0)}',
                    color: AppTheme.warningAmber),
              ],
            ),
          ),
          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: ['All', 'Paid', 'Pending', 'Overdue']
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(s,
                              style: const TextStyle(fontSize: 12)),
                          selected: _statusFilter == s,
                          selectedColor: AppTheme.primaryBlue
                              .withValues(alpha: 0.15),
                          onSelected: (_) =>
                              setState(() => _statusFilter = s),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Bills List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: bills.length,
              itemBuilder: (ctx, idx) {
                final bill = bills[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('INV-${bill.id}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(bill.patientName,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            Text(
                              '\$${bill.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.medical_services_outlined,
                                size: 13,
                                color: AppTheme.textSecondary),
                            Text(' ${bill.description}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(width: 16),
                            Icon(Icons.calendar_today,
                                size: 13,
                                color: AppTheme.textSecondary),
                            Text(
                              ' ${DateFormat('MMM dd, yyyy').format(bill.date)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                            ),
                            const Spacer(),
                            StatusChip(status: bill.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
