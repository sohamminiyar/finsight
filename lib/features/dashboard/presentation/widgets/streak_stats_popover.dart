import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class StreakStatsPopover extends StatelessWidget {
  final int currentStreak;
  final double todayExpenses;
  final double dailyLimit;
  final String currencySymbol;

  const StreakStatsPopover({
    super.key,
    required this.currentStreak,
    required this.todayExpenses,
    required this.dailyLimit,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Flame Icon + Current Streak
            Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFF97316),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Streak',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Text(
                '$currentStreak Days',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: const Color(0xFFF97316),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            
            // Row: Spent Today
            _buildStatRow(
              context,
              'Spent Today',
              CurrencyFormatter.format(todayExpenses, symbol: currencySymbol),
              todayExpenses > 0 ? AppColors.expense : AppColors.income,
            ),
            const SizedBox(height: 12),
            
            // Row: Daily Limit
            _buildStatRow(
              context,
              'Daily Limit',
              CurrencyFormatter.format(dailyLimit, symbol: currencySymbol),
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, Color valueColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge(context).copyWith(
            color: valueColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
