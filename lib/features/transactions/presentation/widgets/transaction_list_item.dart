import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/enums/transaction_type.dart';
import '../../domain/models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final String categoryName;
  final IconData categoryIcon;
  final VoidCallback? onDelete;
  final VoidCallback? onLongPress;

  final String symbol;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.categoryIcon,
    required this.symbol,
    this.onDelete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: AppColors.expense,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  categoryIcon,
                  color: isExpense ? AppColors.expense : AppColors.income,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: AppTextStyles.labelLarge(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '$categoryName • ${DateFormat.jm().format(transaction.date)}',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${isExpense ? '-' : '+'}$symbol${transaction.amount.abs().toStringAsFixed(2)}',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: isExpense ? AppColors.expense : AppColors.income,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
