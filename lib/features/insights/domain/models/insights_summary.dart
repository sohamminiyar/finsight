import 'package:flutter/material.dart';

class CategorySpending {
  final String categoryId;
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  CategorySpending({
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class MonthComparison {
  final String categoryName;
  final double currentAmount;
  final double previousAmount;

  MonthComparison({
    required this.categoryName,
    required this.currentAmount,
    required this.previousAmount,
  });
}

class InsightsSummary {
  final double totalSpending;
  final double previousMonthTotal;
  final String smartTip;
  final List<CategorySpending> categories;
  final CategorySpending? highestCategory;
  final List<MonthComparison> comparisons;

  InsightsSummary({
    required this.totalSpending,
    required this.previousMonthTotal,
    required this.smartTip,
    required this.categories,
    this.highestCategory,
    required this.comparisons,
  });
}
