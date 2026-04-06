import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/insights_summary.dart';
import '../../../transactions/providers/transaction_providers.dart';
import '../../../transactions/domain/models/transaction_model.dart';

class DonutSpendingBreakdown extends ConsumerStatefulWidget {
  final InsightsSummary summary;

  const DonutSpendingBreakdown({super.key, required this.summary});

  @override
  ConsumerState<DonutSpendingBreakdown> createState() => _DonutSpendingBreakdownState();
}

class _DonutSpendingBreakdownState extends ConsumerState<DonutSpendingBreakdown> {
  int touchedIndex = -1;
  bool isHolding = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          // Handle Explicit Touch End
                          if (event is FlTapUpEvent || 
                              event is FlPanEndEvent || 
                              event is FlPointerExitEvent) {
                            touchedIndex = -1;
                            isHolding = false;
                            return;
                          }

                          // If we are already holding, don't let a null touchResponse reset it
                          // (this happens if the user jitters their finger slightly off the segment)
                          final responseIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                          
                          if (event is FlTapDownEvent || event is FlPanStartEvent || event is FlPanUpdateEvent) {
                            isHolding = true;
                            // Update index only if we have a valid new section, otherwise keep the old one
                            if (responseIndex != -1) {
                              touchedIndex = responseIndex;
                            }
                          }
                        });
                      },
                    ),
                    sectionsSpace: 4,
                    centerSpaceRadius: 80,
                    sections: widget.summary.categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final cat = entry.value;
                      final isTouched = index == touchedIndex;
                      final fontSize = isTouched ? 16.0 : 12.0;
                      final radius = isTouched ? 30.0 : 20.0;
                      final shadow = isTouched
                          ? [
                              Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 2)
                            ]
                          : <Shadow>[];

                      return PieChartSectionData(
                        color: cat.color,
                        value: cat.amount,
                        title: '${cat.percentage.toStringAsFixed(0)}%',
                        radius: radius,
                        titleStyle: AppTextStyles.labelSmall(context).copyWith(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: shadow,
                        ),
                        showTitle: false,
                      );
                    }).toList(),
                  ),
                ),
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isHolding && touchedIndex != -1
                        ? _buildCenterSummary(context, widget.summary.categories[touchedIndex])
                        : Column(
                            key: const ValueKey('total_view'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOTAL',
                                style: AppTextStyles.labelSmall(context).copyWith(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(widget.summary.totalSpending),
                                style: AppTextStyles.headlineMedium(context).copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isHolding && touchedIndex != -1
                ? _buildDetailTransactionList(context, widget.summary.categories[touchedIndex])
                : _buildCategoricalBreakdown(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterSummary(BuildContext context, CategorySpending category) {
    return Container(
      key: ValueKey('center_${category.categoryId}'),
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, color: category.color, size: 24),
          const SizedBox(height: 8),
          Text(
            category.name.toUpperCase(),
            style: AppTextStyles.labelSmall(context).copyWith(
              color: category.color,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoricalBreakdown(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      key: const ValueKey('category_list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: AppTextStyles.titleMedium(context).copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.summary.categories.take(5).map((cat) => _buildCategoryRow(context, cat)),
      ],
    );
  }

  Widget _buildDetailTransactionList(BuildContext context, CategorySpending category) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Column(
      key: ValueKey('transaction_list_${category.categoryId}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent ${category.name} Transactions',
                style: AppTextStyles.titleMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  color: category.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.history_rounded, size: 18, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        transactionsAsync.when(
          data: (txs) {
            final categoryTxs = txs
                .where((t) => t.categoryId == category.categoryId)
                .take(5)
                .toList();

            if (categoryTxs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No transactions found for this category',
                    style: AppTextStyles.bodySmall(context),
                  ),
                ),
              );
            }

            return Column(
              children: categoryTxs
                  .map((t) => _buildTransactionRow(context, t))
                  .toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading transactions')),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(BuildContext context, TransactionModel t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dateFormat.format(t.date),
              style: AppTextStyles.labelSmall(context).copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.title,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            currencyFormat.format(t.amount),
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, CategorySpending cat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: cat.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cat.name,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            currencyFormat.format(cat.amount),
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
