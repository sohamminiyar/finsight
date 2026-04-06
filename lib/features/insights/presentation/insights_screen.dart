import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_top_navbar.dart';
import '../providers/insights_provider.dart';
import 'widgets/donut_spending_breakdown.dart';
import 'widgets/highest_category_alert.dart';
import 'widgets/monthly_category_comparison.dart';
import 'widgets/smart_tip_box.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insightsAsync = ref.watch(insightsSummaryProvider);

    return Scaffold(
      appBar: const AppTopNavbar(
        title: 'Insights',
      ),
      body: insightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (summary) {
          if (summary.totalSpending <= 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 80,
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No data for insights yet',
                      style: AppTextStyles.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your financial pulse will beat here once you start tracking your spending.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Centered Page Header
                const SizedBox(height: 8),
                _buildPulseHeader(context),
                const SizedBox(height: 32),
                DonutSpendingBreakdown(summary: summary),
                const SizedBox(height: 32),
                if (summary.highestCategory != null)
                  HighestCategoryAlert(category: summary.highestCategory!),
                const SizedBox(height: 32),
                MonthlyCategoryComparison(comparisons: summary.comparisons),
                const SizedBox(height: 32),
                SmartTipBox(
                  tip: summary.smartTip,
                ),
                const SizedBox(height: 100), // Additional padding for bottom nav
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPulseHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.headlineLarge(context).copyWith(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1E293B),
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
            children: [
              const TextSpan(text: 'Your Financial '),
              TextSpan(
                text: 'Pulse',
                style: TextStyle(
                  color: isDark ? AppColors.primary : const Color(0xFF0F6292),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Understanding the momentum of your capital through visual clarity and editorial precision.',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
