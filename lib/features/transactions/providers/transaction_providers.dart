import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import '../domain/repositories/i_transaction_repository.dart';
import '../data/repositories/sqlite_transaction_repository.dart';
import '../domain/models/transaction_model.dart';
import '../domain/models/category_model.dart';
import '../domain/enums/transaction_type.dart';

part 'transaction_providers.g.dart';

@Riverpod(keepAlive: true)
Database appDatabase(Ref ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main.dart');
}

@riverpod
ITransactionRepository transactionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqliteTransactionRepository(db);
}

@riverpod
FutureOr<List<CategoryModel>> categories(Ref ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.fetchCategories();
}

@riverpod
class TransactionList extends _$TransactionList {
  @override
  FutureOr<List<TransactionModel>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.fetchTransactions();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final repository = ref.watch(transactionRepositoryProvider);
    await repository.insertTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final repository = ref.watch(transactionRepositoryProvider);
    await repository.updateTransaction(transaction);
    ref.invalidateSelf();
  }

  Future<void> deleteTransaction(String id) async {
    final repository = ref.watch(transactionRepositoryProvider);
    await repository.deleteTransaction(id);
    ref.invalidateSelf();
  }
}

final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);
