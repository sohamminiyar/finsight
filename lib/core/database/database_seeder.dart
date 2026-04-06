import 'package:sqflite/sqflite.dart';
import 'dart:math';
import 'database_tables.dart';
import '../../features/transactions/domain/enums/transaction_type.dart';

class DatabaseSeeder {
  static Future<void> seedInitialData(Database db) async {
    final random = Random();

    // Helper functions to generate simple random IDs since we might not have uuid package installed yet
    String generateId() {
      return DateTime.now().microsecondsSinceEpoch.toString() + random.nextInt(10000).toString();
    }

    // 1. Seed Categories
    final categories = [
      {
        'id': generateId(),
        'name': 'Groceries',
        'icon_path': 'assets/icons/groceries.png',
        'color_hex': '#34D399',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Salary',
        'icon_path': 'assets/icons/salary.png',
        'color_hex': '#38BDF8',
        'type': TransactionType.income.name,
      },
      {
        'id': generateId(),
        'name': 'Transport',
        'icon_path': 'assets/icons/transport.png',
        'color_hex': '#FB7185',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Entertainment',
        'icon_path': 'assets/icons/entertainment.png',
        'color_hex': '#FBBF24',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Dining',
        'icon_path': 'assets/icons/dining.png',
        'color_hex': '#A78BFA',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Freelance',
        'icon_path': 'assets/icons/freelance.png',
        'color_hex': '#818CF8',
        'type': TransactionType.income.name,
      },
      {
        'id': generateId(),
        'name': 'Gym',
        'icon_path': 'assets/icons/gym.png',
        'color_hex': '#4ADE80',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Medicine',
        'icon_path': 'assets/icons/medicine.png',
        'color_hex': '#F472B6',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Miscellaneous',
        'icon_path': 'assets/icons/miscellaneous.png',
        'color_hex': '#94A3B8',
        'type': TransactionType.expense.name,
      },
      {
        'id': generateId(),
        'name': 'Subscription',
        'icon_path': 'assets/icons/subscription.png',
        'color_hex': '#F87171',
        'type': TransactionType.expense.name,
      },
    ];

    for (final category in categories) {
      await db.insert(DatabaseTables.categoriesTable, category);
    }

    // 2. Seed Transactions
    final expenseCategories = categories.where((c) => c['type'] == TransactionType.expense.name).toList();
    final incomeCategories = categories.where((c) => c['type'] == TransactionType.income.name).toList();

    final now = DateTime.now();

    for (int i = 0; i < 40; i++) {
      final isIncome = random.nextDouble() > 0.8; // 20% income, 80% expense
      final category = isIncome 
          ? incomeCategories[random.nextInt(incomeCategories.length)]
          : expenseCategories[random.nextInt(expenseCategories.length)];
      
      final amount = isIncome 
          ? (random.nextDouble() * 2000 + 500).roundToDouble() 
          : (random.nextDouble() * 100 + 5).roundToDouble();
          
      final daysAgo = random.nextInt(30);
      final mockDate = now.subtract(Duration(days: daysAgo, hours: random.nextInt(24), minutes: random.nextInt(60)));
      
      final transaction = {
        'id': generateId(),
        'title': '${category['name']} Transaction',
        'category_id': category['id'],
        'amount': amount,
        'note': 'Mock ${isIncome ? 'income' : 'expense'} transaction',
        'date': mockDate.toIso8601String(),
        'type': category['type'],
      };

      await db.insert(DatabaseTables.transactionsTable, transaction);
    }
  }
}
