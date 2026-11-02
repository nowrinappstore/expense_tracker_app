import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// Shows an AlertDialog asking the user to confirm deletion.
/// If confirmed, deletes the transaction from the database.
/// Returns true when the transaction was deleted.
Future<bool> confirmAndDelete(
  BuildContext context,
  TransactionModel tx,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
      title: const Text('Delete Transaction'),
      content: Text(
        'Are you sure you want to delete "${tx.title}"? '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true || tx.id == null) return false;

  await DatabaseHelper.instance.deleteTransaction(tx.id!);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
  }
  return true;
}
