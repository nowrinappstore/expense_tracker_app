import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';

/// Form used both to ADD a new transaction and to EDIT an existing one.
///
/// Pass [transaction] to open in edit mode with the saved values pre-filled.
/// Pops with `true` after a successful save.
class AddEditTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  bool get isEditing => transaction != null;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _type;
  String? _category;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _titleController.text = tx.title;
      _amountController.text = _trimAmount(tx.amount);
      _type = tx.type;
      _category = tx.category;
      _date = tx.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// 1500.0 -> "1500", 12.5 -> "12.5"
  String _trimAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  // ---------------- Validators ----------------

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title cannot be empty';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  // ---------------- Actions ----------------

  void _onTypeChanged(String type) {
    setState(() {
      _type = type;
      // Reset category if it does not belong to the newly chosen type.
      if (_category != null && !categoriesFor(type).contains(_category)) {
        _category = null;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final tx = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: _type!,
      date: DateTime(_date.year, _date.month, _date.day),
    );

    final db = DatabaseHelper.instance;
    if (widget.isEditing) {
      await db.updateTransaction(tx);
    } else {
      await db.insertTransaction(tx);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEditing
            ? 'Transaction updated'
            : 'Transaction added'),
      ),
    );
    Navigator.pop(context, true);
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Grocery shopping',
                prefixIcon: Icon(Icons.title),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              validator: _validateTitle,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                hintText: 'e.g. 250.00',
                prefixIcon: Icon(Icons.payments_outlined),
                prefixText: '$kCurrency ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: _validateAmount,
            ),
            const SizedBox(height: 20),

            // Transaction Type (Income / Expense)
            FormField<String>(
              validator: (_) =>
                  _type == null ? 'Please select a transaction type' : null,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Type',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: TxType.all.map((t) {
                        final selected = _type == t;
                        final color = colorForType(t);
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: t == TxType.income ? 6 : 0,
                              left: t == TxType.expense ? 6 : 0,
                            ),
                            child: ChoiceChip(
                              label: Text(t),
                              avatar: Icon(
                                t == TxType.income
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: selected ? Colors.white : color,
                                size: 18,
                              ),
                              showCheckmark: false,
                              selected: selected,
                              selectedColor: color,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : color,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(color: color),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onSelected: (_) {
                                _onTypeChanged(t);
                                field.didChange(t);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 12),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Category (DropdownButton)
            FormField<String>(
              validator: (_) =>
                  _category == null ? 'Please select a category' : null,
              builder: (field) {
                final items = categoriesFor(_type);
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    errorText: field.errorText,
                    helperText:
                        _type == null ? 'Select a transaction type first' : null,
                  ),
                  isEmpty: _category == null,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isDense: true,
                      isExpanded: true,
                      hint: const Text('Select category'),
                      items: items
                          .map((c) => DropdownMenuItem<String>(
                                value: c,
                                child: Row(
                                  children: [
                                    Icon(iconForCategory(c), size: 20),
                                    const SizedBox(width: 10),
                                    Text(c),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: items.isEmpty
                          ? null
                          : (value) {
                              setState(() => _category = value);
                              field.didChange(value);
                            },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Date (Date Picker)
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                child: Text(formatDate(_date)),
              ),
            ),
            const SizedBox(height: 32),

            // Save
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(widget.isEditing ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
