import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../providers/dashboard_provider.dart';
import '../../transactions/providers/transaction_providers.dart';
import '../../transactions/domain/enums/transaction_type.dart';
import 'package:finsight/features/profile/providers/settings_provider.dart';
import 'widgets/balance_header_card.dart';
import 'widgets/spending_line_chart.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/streak_widget.dart';
import 'widgets/savings_goal_ring.dart';
import '../../../shared/widgets/app_top_navbar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboardSummaryAsync = ref.watch(dashboardSummaryProvider);
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final currencySymbol = settingsAsync.maybeWhen(
      data: (s) => s.currencySymbol,
      orElse: () => '₹',
    );
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) return 'Good morning';
      if (hour >= 12 && hour < 17) return 'Good afternoon';
      if (hour >= 17 && hour < 22) return 'Good evening';
      return 'Good night';
    }

    // Responsive Dimensions
    final screenSize = MediaQuery.sizeOf(context);
    final hPadding = screenSize.width * 0.06; // 6% of width for consistent margins
    const vSpacing = 24.0; // Standardized spacing between all components

    return Scaffold(
      body: dashboardSummaryAsync.when(
        data: (summary) => CustomScrollView(
          slivers: [
            SliverAppTopNavbar(
              title: 'Dashboard',
              streakDays: summary.streakDays,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    settingsAsync.maybeWhen(
                      data: (settings) => Text(
                        '${getGreeting()}, ${settings.userName}',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      orElse: () => Text(
                        '${getGreeting()}, User',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: vSpacing),
                    BalanceHeaderCard(
                      balance: summary.currentBalance,
                      totalIncome: summary.totalIncome,
                      totalExpenses: summary.totalExpenses,
                      currencySymbol: currencySymbol,
                      onIncomeTap: () {
                        ref.read(transactionTypeFilterProvider.notifier).state = TransactionType.income;
                        context.go('/transactions');
                      },
                      onExpenseTap: () {
                        ref.read(transactionTypeFilterProvider.notifier).state = TransactionType.expense;
                        context.go('/transactions');
                      },
                    ),
                    const SizedBox(height: vSpacing),
                    SavingsGoalRing(
                      currentSavings: summary.totalIncome - summary.totalExpenses,
                      targetSavings: summary.targetSavings,
                      progress: summary.savingsProgress,
                      hasReachedGoal: summary.hasReachedGoal,
                      isOverspent: summary.isOverspent,
                    ),
                    const SizedBox(height: vSpacing),
                    const SpendingLineChart(),
                    const SizedBox(height: vSpacing),
                    const RecentTransactionsList(),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const CustomScrollView(
          slivers: [
            SliverAppBar(floating: true, pinned: true, elevation: 0, title: Text('Flow', style: TextStyle(color: AppColors.primary))),
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
        error: (err, stack) => CustomScrollView(
          slivers: [
            SliverAppBar(floating: true, pinned: true, elevation: 0, title: Text('Flow', style: TextStyle(color: AppColors.primary))),
            SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-transaction'),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
