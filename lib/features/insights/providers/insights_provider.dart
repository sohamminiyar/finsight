import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../transactions/domain/enums/transaction_type.dart';
import '../domain/models/insights_summary.dart';
import '../../../core/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final insightsSummaryProvider = Provider<AsyncValue<InsightsSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  if (transactionsAsync.isLoading || categoriesAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (transactionsAsync.hasError || categoriesAsync.hasError) {
    return AsyncValue.error(
      transactionsAsync.error ?? categoriesAsync.error!,
      transactionsAsync.stackTrace ?? categoriesAsync.stackTrace!,
    );
  }

  final transactions = transactionsAsync.value ?? [];
  final allCategories = categoriesAsync.value ?? [];

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  final previousMonthDate = DateTime(now.year, now.month - 1);
  final previousMonth = previousMonthDate.month;
  final previousYear = previousMonthDate.year;

  // 1. Group Current Month Expenses by Category
  final currentMonthExpenses = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.month == currentMonth &&
      t.date.year == currentYear).toList();

  final Map<String, double> categoryTotals = {};
  double totalSpending = 0;

  for (final t in currentMonthExpenses) {
    categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
    totalSpending += t.amount;
  }

  // 2. Create CategorySpending List
  final List<CategorySpending> spendingList = [];
  for (final entry in categoryTotals.entries) {
    // Defensive lookup: handle missing categories gracefully
    final categoryModels = allCategories.where((c) => c.id == entry.key);
    
    if (categoryModels.isEmpty) {
      // Fallback for missing/deleted categories
      spendingList.add(CategorySpending(
        categoryId: entry.key,
        name: 'Unknown',
        amount: entry.value,
        percentage: totalSpending > 0 ? (entry.value / totalSpending) * 100 : 0,
        color: Colors.grey,
        icon: Icons.help_outline,
      ));
      continue;
    }

    final cat = categoryModels.first;
    spendingList.add(CategorySpending(
      categoryId: entry.key,
      name: cat.name,
      amount: entry.value,
      percentage: totalSpending > 0 ? (entry.value / totalSpending) * 100 : 0,
      color: Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF'))),
      icon: IconMapper.getIcon(cat.iconPath),
    ));
  }

  // Sort by amount descending
  spendingList.sort((a, b) => b.amount.compareTo(a.amount));

  // 3. Previous Month for Comparison
  final prevMonthExpenses = transactions.where((t) =>
      t.type == TransactionType.expense &&
      t.date.month == previousMonth &&
      t.date.year == previousYear).toList();

  final Map<String, double> prevCategoryTotals = {};
  double previousMonthTotal = 0;
  for (final t in prevMonthExpenses) {
    prevCategoryTotals[t.categoryId] = (prevCategoryTotals[t.categoryId] ?? 0) + t.amount;
    previousMonthTotal += t.amount;
  }

  // 4. Comparison List (Top 4 categories by current amount)
  final comparisons = spendingList.take(4).map((curr) {
    return MonthComparison(
      categoryName: curr.name,
      currentAmount: curr.amount,
      previousAmount: prevCategoryTotals[curr.categoryId] ?? 0,
    );
  }).toList();

  // 5. Dynamic Smart Tip Generation
  final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
  String smartTip = "Your spending is on track for this month. Keep it up!";

  if (totalSpending > 0) {
    if (previousMonthTotal > 0) {
      final diff = totalSpending - previousMonthTotal;
      if (diff < 0) {
        smartTip = "Great job! You've spent ${currencyFormat.format(diff.abs())} less than last month. Consider moving this to your savings.";
      } else if (diff > 0) {
        // Find the category with the highest increase
        String highestIncreaseCat = "";
        double maxIncrease = 0;
        
        for (final comp in comparisons) {
          final increase = comp.currentAmount - comp.previousAmount;
          if (increase > maxIncrease) {
            maxIncrease = increase;
            highestIncreaseCat = comp.categoryName;
          }
        }
        
        if (highestIncreaseCat.isNotEmpty) {
          smartTip = "Your spending on $highestIncreaseCat is up by ${currencyFormat.format(maxIncrease)} from last month. Reviewing your $highestIncreaseCat habits could save you more.";
        } else {
          smartTip = "You've spent ${currencyFormat.format(diff)} more than last month. Try to identify non-essential expenses to cut back.";
        }
      }
    } else {
      smartTip = "You've started tracking your expenses! Aim to keep your ${spendingList.first.name} spending within your budget next month.";
    }
  }

  return AsyncValue.data(InsightsSummary(
    totalSpending: totalSpending,
    previousMonthTotal: previousMonthTotal,
    smartTip: smartTip,
    categories: spendingList,
    highestCategory: spendingList.isNotEmpty ? spendingList.first : null,
    comparisons: comparisons,
  ));
});
