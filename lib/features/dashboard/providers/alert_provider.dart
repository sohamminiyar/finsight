import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../transactions/domain/enums/transaction_type.dart';
import '../../profile/providers/settings_provider.dart';
import 'dashboard_provider.dart';
import '../domain/models/smart_alert.dart';

part 'alert_provider.g.dart';

@riverpod
List<SmartAlert> smartAlerts(SmartAlertsRef ref) {
  final summaryAsync = ref.watch(dashboardSummaryProvider);
  final transactionsAsync = ref.watch(transactionListProvider);
  final settingsAsync = ref.watch(profileSettingsNotifierProvider);

  final summary = summaryAsync.valueOrNull;
  final transactions = transactionsAsync.valueOrNull ?? [];
  final settings = settingsAsync.valueOrNull;

  if (summary == null || settings == null) return [];

  final List<SmartAlert> alerts = [];
  final now = DateTime.now();

  // 1. Daily Check: Overspending today
  final todayExpenses = transactions
      .where((t) =>
          t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month &&
          t.date.day == now.day)
      .fold(0.0, (sum, t) => sum + t.amount);

  if (todayExpenses > settings.dailySpendingLimit) {
    alerts.add(SmartAlert(
      title: 'Daily Limit Exceeded',
      message: 'You spent ₹${(todayExpenses - settings.dailySpendingLimit).toStringAsFixed(0)} over your budget today.',
      type: AlertType.warning,
    ));
  }

  // 2. Savings Hierarchy (Recursive/Exclusive check)
  if (summary.currentBalance >= settings.monthlySavingsTarget) {
    alerts.add(const SmartAlert(
      title: 'Goal Achieved! 🎉',
      message: 'Excellent work! You reached your monthly savings target.',
      type: AlertType.success,
    ));
  } else if (summary.currentBalance >= (settings.monthlySavingsTarget * 0.5) && summary.currentBalance > 0) {
    alerts.add(const SmartAlert(
      title: 'Keep Going!',
      message: 'You reached 50% of your savings goal. Stay focused!',
      type: AlertType.info,
    ));
  } else if (summary.currentBalance < 0) {
    alerts.add(const SmartAlert(
      title: 'Negative Savings Warning',
      message: 'Your spending is currently exceeding your income this month.',
      type: AlertType.warning,
    ));
  }

  return alerts;
}
