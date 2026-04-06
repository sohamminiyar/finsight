import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../../transactions/domain/enums/transaction_type.dart';
import '../../../transactions/providers/transaction_providers.dart';
import 'package:finsight/features/profile/providers/settings_provider.dart';
import '../../../../shared/widgets/async_value_widget.dart';

class RecentTransactionsList extends ConsumerWidget {
  const RecentTransactionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(transactionListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => s.currencySymbol,
      orElse: () => '₹',
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go('/transactions'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AsyncValueWidget(
            value: transactionsAsync,
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 60,
                          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: AppTextStyles.labelLarge(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Take 5 most recent
              final recentItems = transactions.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: recentItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final transaction = recentItems[index];
                  
                  return categoriesAsync.when(
                    data: (categories) {
                      final category = categories.firstWhere(
                        (c) => c.id == transaction.categoryId,
                        orElse: () => categories.first,
                      );
                      
                      return _buildTransactionItem(
                        context,
                        title: transaction.title,
                        category: category.name,
                        amount: transaction.amount,
                        type: transaction.type,
                        symbol: currencySymbol,
                        icon: _getIconFromCategory(category.name),
                      );
                    },
                    loading: () => const SizedBox(height: 48),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconFromCategory(String name) {
    switch (name.toLowerCase()) {
      case 'groceries': return Icons.shopping_basket_rounded;
      case 'salary': return Icons.account_balance_wallet_rounded;
      case 'transport': return Icons.directions_bus_rounded;
      case 'entertainment': return Icons.movie_creation_rounded;
      case 'dining': return Icons.restaurant_rounded;
      case 'freelance': return Icons.laptop_mac_rounded;
      default: return Icons.category_rounded;
    }
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String category,
    required double amount,
    required TransactionType type,
    required String symbol,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = type == TransactionType.expense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: (isExpense ? AppColors.expense : AppColors.income).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: isExpense ? AppColors.expense : AppColors.income,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  category,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isExpense ? '-' : '+'}$symbol${amount.abs().toStringAsFixed(2)}',
            style: AppTextStyles.labelLarge(context).copyWith(
              color: isExpense ? AppColors.expense : AppColors.income,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
