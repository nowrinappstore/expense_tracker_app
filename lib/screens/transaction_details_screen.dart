import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/dialogs.dart';
import 'add_edit_transaction_screen.dart';

/// Shows complete information for one transaction with Edit and Delete.
///
/// Pops with `true` if the transaction was changed or deleted,
/// so the previous screen knows to refresh.
class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionModel _tx;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _tx = widget.transaction;
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(transaction: _tx),
      ),
    );
    if (updated == true && _tx.id != null) {
      final fresh = await DatabaseHelper.instance.getTransactionById(_tx.id!);
      if (!mounted || fresh == null) return;
      setState(() {
        _tx = fresh;
        _changed = true;
      });
    }
  }

  Future<void> _delete() async {
    final deleted = await confirmAndDelete(context, _tx);
    if (deleted && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorForType(_tx.type);
    final isIncome = _tx.type == TxType.income;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: _edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _delete,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header card with amount
            Card(
              elevation: 0,
              color: color.withAlpha(25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: color.withAlpha(40),
                      child: Icon(iconForCategory(_tx.category),
                          color: color, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _tx.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isIncome ? '+' : '-'} ${formatAmount(_tx.amount)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _row(Icons.tag, 'Transaction ID', '#${_tx.id}'),
                  const Divider(height: 1),
                  _row(Icons.title, 'Title', _tx.title),
                  const Divider(height: 1),
                  _row(Icons.payments_outlined, 'Amount',
                      formatAmount(_tx.amount)),
                  const Divider(height: 1),
                  _row(Icons.category_outlined, 'Category', _tx.category),
                  const Divider(height: 1),
                  _row(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    'Type',
                    _tx.type,
                    valueColor: color,
                  ),
                  const Divider(height: 1),
                  _row(Icons.calendar_today_outlined, 'Date',
                      formatDate(_tx.date)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete'),
                    style: FilledButton.styleFrom(
                      backgroundColor: kExpenseColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color? valueColor}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: TextStyle(color: Colors.grey.shade700)),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ),
    );
  }
}
