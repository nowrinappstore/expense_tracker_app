/// A single income or expense entry.
///
/// Named `TransactionModel` (not `Transaction`) to avoid clashing with
/// sqflite's own `Transaction` class.
class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final String type; // 'Income' or 'Expense'
  final DateTime date;

  const TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: map['type'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? category,
    String? type,
    DateTime? date,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
    );
  }
}
