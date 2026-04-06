import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BalanceHeaderCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  final String currencySymbol;

  const BalanceHeaderCard({
    super.key, 
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.currencySymbol,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    // Scale balance text for small screens
    final balanceFontSize = screenWidth < 360 ? 32.0 : 40.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: AppTextStyles.labelLarge(context).copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$currencySymbol${balance.toStringAsFixed(2)}',
              style: AppTextStyles.displayLarge(context).copyWith(
                color: Colors.white,
                fontSize: balanceFontSize,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildClickableSummary(
                  context,
                  label: 'Income',
                  value: '+$currencySymbol${totalIncome.toStringAsFixed(2)}',
                  color: AppColors.income,
                  onTap: onIncomeTap,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildClickableSummary(
                  context,
                  label: 'Expenses',
                  value: '-$currencySymbol${totalExpenses.toStringAsFixed(2)}',
                  color: AppColors.expense,
                  onTap: onExpenseTap,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClickableSummary(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required VoidCallback? onTap,
    required CrossAxisAlignment crossAxisAlignment,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  textAlign: crossAxisAlignment == CrossAxisAlignment.end 
                      ? TextAlign.end 
                      : TextAlign.start,
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
