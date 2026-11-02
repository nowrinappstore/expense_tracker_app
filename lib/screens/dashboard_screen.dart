import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/dialogs.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';
import 'transaction_details_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int _recentCount = 5;

  final _db = DatabaseHelper.instance;

  double _totalIncome = 0;
  double _totalExpense = 0;
  List<TransactionModel> _recent = [];
  bool _loading = true;

  double get _balance => _totalIncome - _totalExpense;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Reloads totals and recent transactions from the database.
  Future<void> _loadData() async {
    final income = await _db.getTotalIncome();
    final expense = await _db.getTotalExpense();
    final recent = await _db.getAllTransactions(limit: _recentCount);
    if (!mounted) return;
    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
      _recent = recent;
      _loading = false;
    });
  }

  Future<void> _openAdd() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openDetails(TransactionModel tx) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: tx)),
    );
    if (changed == true) _loadData();
  }

  Future<void> _openAll() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TransactionListScreen()),
    );
    // Always refresh: the list screen may have edited or deleted items.
    _loadData();
  }

  Future<void> _delete(TransactionModel tx) async {
    final deleted = await confirmAndDelete(context, tx);
    if (deleted) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        tooltip: 'Add Transaction',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 96),
                // 1 header (summary + title row) + recent items (or 1 empty state)
                itemCount: 1 + (_recent.isEmpty ? 1 : _recent.length),
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeader();
                  if (_recent.isEmpty) return _buildEmptyState();
                  final tx = _recent[index - 1];
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Total Income',
                  amount: _totalIncome,
                  color: kIncomeColor,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryCard(
                  label: 'Total Expense',
                  amount: _totalExpense,
                  color: kExpenseColor,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SummaryCard(
            label: 'Current Balance',
            amount: _balance,
            color: _balance < 0 ? kExpenseColor : kBalanceColor,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: _openAll,
                child: const Text('See All'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No transactions yet.\nTap "Add" to create your first one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
