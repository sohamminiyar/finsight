import '../models/transaction_model.dart';
import '../models/category_model.dart';

abstract class ITransactionRepository {
  Future<List<TransactionModel>> fetchTransactions();
  Future<void> insertTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<bool> hasExpenseToday();
  
  Future<TransactionModel?> fetchTransactionById(String id);
  Future<List<CategoryModel>> fetchCategories();
  Future<void> insertCategory(CategoryModel category);
  Future<void> deleteAllTransactions();
}
