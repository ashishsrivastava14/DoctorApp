import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../mock_data/mock_billing.dart';
import '../../../models/billing_model.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  late List<BillingModel> _bills;
  String _statusFilter = 'All';
  String _search = '';

  @override
  void initState() {
    super.initState();
    _bills = mockBillings.toList();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  List<BillingModel> get _filtered {
    var list = _bills;
    if (_statusFilter != 'All') {
      list = list.where((b) => b.status == _statusFilter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((b) =>
              b.patientName.toLowerCase().contains(q) ||
              b.doctorName.toLowerCase().contains(q) ||
              b.description.toLowerCase().contains(q) ||
              b.id.toLowerCase().contains(q))
          .toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double _sum(String? status) => _bills
      .where((b) => status == null || b.status == status)
      .fold(0, (s, b) => s + b.amount);

  // ── View Details ──────────────────────────────────────────────────────────

  void _viewDetails(BillingModel bill) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Invoice #INV-${bill.id}',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                StatusChip(status: bill.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _DetailRow(Icons.person_outline, 'Patient', bill.patientName),
            _DetailRow(Icons.medical_services_outlined, 'Doctor',
                bill.doctorName),
            _DetailRow(Icons.description_outlined, 'Description',
                bill.description),
            _DetailRow(
                Icons.calendar_today_outlined,
                'Date',
                DateFormat('MMM dd, yyyy').format(bill.date)),
            _DetailRow(Icons.payment_outlined, 'Payment Method',
                bill.paymentMethod),
            _DetailRow(Icons.tag, 'Appointment ID', bill.appointmentId),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('\$${bill.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (bill.status != 'Paid')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline,
                          size: 16),
                      label: const Text('Mark as Paid'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _markAs(bill, 'Paid');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(
                              color: AppTheme.errorRed),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _confirmDelete(bill);
                      },
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete Record'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side:
                          const BorderSide(color: AppTheme.errorRed),
                      padding:
                          const EdgeInsets.symmetric(vertical: 12)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confirmDelete(bill);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Mark status ───────────────────────────────────────────────────────────

  void _markAs(BillingModel bill, String status) {
    final idx = _bills.indexWhere((b) => b.id == bill.id);
    if (idx == -1) return;
    setState(() => _bills[idx] = _bills[idx].copyWith(status: status));
    _snack('INV-${bill.id} marked as $status.');
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  void _confirmDelete(BillingModel bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text(
            'Remove invoice INV-${bill.id} for ${bill.patientName}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white),
            onPressed: () {
              setState(
                  () => _bills.removeWhere((b) => b.id == bill.id));
              Navigator.of(ctx).pop();
              _snack('Invoice INV-${bill.id} deleted.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ── Add Invoice ───────────────────────────────────────────────────────────

  void _openAddInvoice() {
    final patientCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String payMethod = 'Card';
    String status = 'Pending';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2))),
                  ),
                  const Text('New Invoice',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: patientCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: doctorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Doctor Name',
                      prefixIcon:
                          Icon(Icons.medical_services_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (\$)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      return n == null || n <= 0
                          ? 'Enter a valid amount'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: payMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Card', 'Cash', 'UPI', 'Insurance']
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => payMethod = v ?? payMethod),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.info_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Pending', 'Paid', 'Overdue']
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) =>
                        setLocal(() => status = v ?? status),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        if (!(formKey.currentState?.validate() ??
                            false)) {
                          return;
                        }
                        final newBill = BillingModel(
                          id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
                          patientId: 'pat_new',
                          patientName: patientCtrl.text.trim(),
                          doctorId: 'doc_new',
                          doctorName: doctorCtrl.text.trim(),
                          appointmentId: 'apt_new',
                          date: DateTime.now(),
                          amount:
                              double.tryParse(amountCtrl.text) ?? 0,
                          status: status,
                          paymentMethod: payMethod,
                          description: descCtrl.text.trim(),
                        );
                        setState(() => _bills.add(newBill));
                        Navigator.of(ctx).pop();
                        _snack(
                            'Invoice for ${newBill.patientName} added.');
                      },
                      child: const Text('Create Invoice'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing & Payments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search patient, doctor...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _SummaryCard(
                    label: 'Total',
                    value: '\$${_sum(null).toStringAsFixed(0)}',
                    color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                _SummaryCard(
                    label: 'Paid',
                    value: '\$${_sum('Paid').toStringAsFixed(0)}',
                    color: AppTheme.successGreen),
                const SizedBox(width: 8),
                _SummaryCard(
                    label: 'Pending',
                    value: '\$${_sum('Pending').toStringAsFixed(0)}',
                    color: AppTheme.warningAmber),
                const SizedBox(width: 8),
                _SummaryCard(
                    label: 'Overdue',
                    value: '\$${_sum('Overdue').toStringAsFixed(0)}',
                    color: AppTheme.errorRed),
              ],
            ),
          ),
          // Filter — use SingleChildScrollView to avoid overflow
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                    '${displayed.length} record${displayed.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          // Bills List
          Expanded(
            child: displayed.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('No records found',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: displayed.length,
                    itemBuilder: (ctx, idx) {
                      final bill = displayed[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _viewDetails(bill),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text(bill.patientName,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme
                                                      .textSecondary)),
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
                                    Expanded(
                                      child: Text(
                                        ' ${bill.description}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusChip(status: bill.status),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 12,
                                        color: AppTheme.textSecondary),
                                    Text(
                                      ' ${DateFormat('MMM dd, yyyy').format(bill.date)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary),
                                    ),
                                    const Spacer(),
                                    // Quick action buttons
                                    if (bill.status == 'Pending' ||
                                        bill.status == 'Overdue')
                                      InkWell(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        onTap: () =>
                                            _markAs(bill, 'Paid'),
                                        child: Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.successGreen
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text('Mark Paid',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppTheme.successGreen,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ),
                                    const SizedBox(width: 6),
                                    PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      iconSize: 18,
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                            value: 'view',
                                            child: Row(children: [
                                              Icon(
                                                  Icons
                                                      .visibility_outlined,
                                                  size: 16),
                                              SizedBox(width: 8),
                                              Text('View Details'),
                                            ])),
                                        if (bill.status != 'Paid')
                                          const PopupMenuItem(
                                              value: 'paid',
                                              child: Row(children: [
                                                Icon(
                                                    Icons
                                                        .check_circle_outline,
                                                    size: 16,
                                                    color: AppTheme
                                                        .successGreen),
                                                SizedBox(width: 8),
                                                Text('Mark as Paid',
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .successGreen)),
                                              ])),
                                        if (bill.status == 'Pending')
                                          const PopupMenuItem(
                                              value: 'overdue',
                                              child: Row(children: [
                                                Icon(
                                                    Icons.warning_outlined,
                                                    size: 16,
                                                    color: AppTheme
                                                        .errorRed),
                                                SizedBox(width: 8),
                                                Text('Mark as Overdue',
                                                    style: TextStyle(
                                                        color: AppTheme
                                                            .errorRed)),
                                              ])),
                                        const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(children: [
                                              Icon(Icons.delete_outline,
                                                  size: 16,
                                                  color:
                                                      AppTheme.errorRed),
                                              SizedBox(width: 8),
                                              Text('Delete',
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .errorRed)),
                                            ])),
                                      ],
                                      onSelected: (v) {
                                        switch (v) {
                                          case 'view':
                                            _viewDetails(bill);
                                            break;
                                          case 'paid':
                                            _markAs(bill, 'Paid');
                                            break;
                                          case 'overdue':
                                            _markAs(bill, 'Overdue');
                                            break;
                                          case 'delete':
                                            _confirmDelete(bill);
                                            break;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddInvoice,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                      text: '$label: ',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  TextSpan(
                      text: value,
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
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
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
