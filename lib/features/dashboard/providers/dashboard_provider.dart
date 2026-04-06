import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../transactions/domain/enums/transaction_type.dart';
import '../../profile/providers/settings_provider.dart';
import '../../profile/domain/models/profile_settings.dart';

part 'dashboard_provider.g.dart';
 
enum ChartPeriod { week, month }
 
@riverpod
class ChartPeriodNotifier extends _$ChartPeriodNotifier {
  @override
  ChartPeriod build() => ChartPeriod.week;
 
  void setPeriod(ChartPeriod period) => state = period;
}

class DashboardSummary {
  final double currentBalance;
  final double totalIncome;
  final double totalExpenses;
  final bool hasExpenseToday;
  final int streakDays;
  final double targetSavings;
  final double savingsProgress;
  final bool hasReachedGoal;
  final bool isOverspent;
  final double todayExpenses;

  DashboardSummary({
    required this.currentBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.hasExpenseToday,
    required this.streakDays,
    required this.targetSavings,
    required this.savingsProgress,
    required this.hasReachedGoal,
    required this.isOverspent,
    required this.todayExpenses,
  });
}

@Riverpod(keepAlive: true)
FutureOr<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final transactionsAsync = ref.watch(transactionListProvider);
  final repository = ref.watch(transactionRepositoryProvider);

  final transactions = transactionsAsync.valueOrNull ?? [];
  
  double income = 0;
  double expenses = 0;

  final now = DateTime.now();

  for (final t in transactions) {
    if (t.date.year == now.year && t.date.month == now.month) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
    }
  }

  final balance = income - expenses;
  final hasExpenseToday = await repository.hasExpenseToday();

  final settingsAsync = ref.watch(profileSettingsNotifierProvider);
  final settings = settingsAsync.valueOrNull ?? const ProfileSettings();

  // Streak calculation: count consecutive days where total expenses <= dailySpendingLimit
  int streak = 0;
  double todayExpensesValue = 0.0;
  for (int i = 0; i < 90; i++) { // Check up to last 90 days
    final checkDate = now.subtract(Duration(days: i));
    final expensesOnDay = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == checkDate.year &&
            t.date.month == checkDate.month &&
            t.date.day == checkDate.day)
        .fold(0.0, (sum, t) => sum + t.amount);

    if (i == 0) todayExpensesValue = expensesOnDay;

    if (expensesOnDay <= settings.dailySpendingLimit) {
      streak++;
    } else {
      // If we broke the limit today, streak is 0. 
      // If we broke it in the past, the streak ends there.
      break;
    }
  }

  final currentSavings = income - expenses;
  final targetSavings = settings.monthlySavingsTarget;
  
  double savingsProgress = 0.0;
  bool hasReachedGoal = false;
  bool isOverspent = false;
  
  if (currentSavings < 0) {
    isOverspent = true;
    savingsProgress = 0.0;
  } else if (targetSavings > 0) {
    savingsProgress = currentSavings / targetSavings;
    if (savingsProgress >= 1.0) {
      savingsProgress = 1.0;
      hasReachedGoal = true;
    }
  }

  return DashboardSummary(
    currentBalance: balance,
    totalIncome: income,
    totalExpenses: expenses,
    hasExpenseToday: hasExpenseToday,
    streakDays: streak == 0 ? 1 : streak, // Default to 1 if tracked today
    targetSavings: targetSavings,
    savingsProgress: savingsProgress,
    hasReachedGoal: hasReachedGoal,
    isOverspent: isOverspent,
    todayExpenses: todayExpensesValue,
  );
}

@Riverpod(keepAlive: true)
FutureOr<List<double>> spendingTrend(SpendingTrendRef ref) async {
  final period = ref.watch(chartPeriodNotifierProvider);
  final transactionsAsync = ref.watch(transactionListProvider);
  final transactions = transactionsAsync.valueOrNull ?? [];
  
  final now = DateTime.now();
  final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

  if (period == ChartPeriod.week) {
    // Last 7 days daily totals
    final result = List.filled(7, 0.0);
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      result[i] = expenses
          .where((t) => t.date.year == date.year && t.date.month == date.month && t.date.day == date.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return result;
  } else {
    // Last 28 days (4 weeks) sliding window split into 7-day chunks
    final result = List.filled(4, 0.0);
    for (int i = 0; i < 4; i++) {
      // Weeks from 3 weeks ago (index 0) to current week (index 3)
      final endOfChunk = now.subtract(Duration(days: (3 - i) * 7));
      final startOfChunk = endOfChunk.subtract(const Duration(days: 6));
      
      // Standardize to midnight for comparison
      final start = DateTime(startOfChunk.year, startOfChunk.month, startOfChunk.day);
      final end = DateTime(endOfChunk.year, endOfChunk.month, endOfChunk.day, 23, 59, 59);

      result[i] = expenses
          .where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && 
                        t.date.isBefore(end.add(const Duration(seconds: 1))))
          .fold(0.0, (sum, t) => sum + t.amount);
    }
    return result;
  }
}
