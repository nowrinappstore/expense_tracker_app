import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/dialogs.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';

/// Shows every transaction using ListView.builder.
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  List<TransactionModel> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await DatabaseHelper.instance.getAllTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = list;
      _loading = false;
    });
  }

  Future<void> _openDetails(TransactionModel tx) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: tx)),
    );
    if (changed == true) _load();
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (changed == true) _load();
  }

  Future<void> _delete(TransactionModel tx) async {
    final deleted = await confirmAndDelete(context, tx);
    if (deleted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 88),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return TransactionTile(
                        transaction: tx,
                        onTap: () => _openDetails(tx),
                        onDelete: () => _delete(tx),
                      );
                    },
                  ),
                ),
    );
  }
}
