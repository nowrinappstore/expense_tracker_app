import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction_model.dart';
import '../utils/constants.dart';

/// Singleton wrapper around the local SQLite database.
///
/// Database: expense_tracker.db
/// Table:    transactions
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;
  static const String tableName = 'transactions';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ---------- CRUD ----------

  Future<int> insertTransaction(TransactionModel tx) async {
    final db = await database;
    return db.insert(tableName, tx.toMap());
  }

  /// All transactions, newest first.
  Future<List<TransactionModel>> getAllTransactions({int? limit}) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<TransactionModel?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionModel.fromMap(rows.first);
  }

  Future<int> updateTransaction(TransactionModel tx) async {
    final db = await database;
    return db.update(
      tableName,
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Summaries ----------

  Future<double> _sumByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) AS total FROM $tableName WHERE type = ?',
      [type],
    );
    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }

  Future<double> getTotalIncome() => _sumByType(TxType.income);

  Future<double> getTotalExpense() => _sumByType(TxType.expense);
}
