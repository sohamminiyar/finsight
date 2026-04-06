import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/category_model.dart';
import '../../domain/enums/transaction_type.dart';
import '../../../../core/database/database_tables.dart';

class SqliteTransactionRepository implements ITransactionRepository {
  final Database _db;

  SqliteTransactionRepository(this._db);

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final result = await _db.query(
      DatabaseTables.transactionsTable,
      orderBy: 'date DESC',
    );
    return result.map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    try {
      await _db.insert(
        DatabaseTables.transactionsTable,
        transaction.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.update(
      DatabaseTables.transactionsTable,
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.delete(
      DatabaseTables.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> hasExpenseToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    final result = await _db.query(
      DatabaseTables.transactionsTable,
      where: 'type = ? AND date >= ? AND date <= ?',
      whereArgs: [TransactionType.expense.name, startOfDay, endOfDay],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  @override
  Future<TransactionModel?> fetchTransactionById(String id) async {
    final result = await _db.query(
      DatabaseTables.transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return TransactionModel.fromJson(result.first.map((k, v) => MapEntry(k, v)));
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final result = await _db.query(DatabaseTables.categoriesTable);
    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertCategory(CategoryModel category) async {
    await _db.insert(
      DatabaseTables.categoriesTable,
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteAllTransactions() async {
    await _db.delete(DatabaseTables.transactionsTable);
  }
}
