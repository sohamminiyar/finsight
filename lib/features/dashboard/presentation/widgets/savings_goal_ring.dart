import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class SavingsGoalRing extends StatelessWidget {
  final double currentSavings;
  final double targetSavings;
  final double progress;
  final bool hasReachedGoal;
  final bool isOverspent;

  const SavingsGoalRing({
    super.key,
    required this.currentSavings,
    required this.targetSavings,
    required this.progress,
    required this.hasReachedGoal,
    required this.isOverspent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Full currency formatting (no shortcuts)
    final currencyFormatter = NumberFormat.simpleCurrency(
      locale: 'en_IN',
      decimalDigits: 0,
    );

    // Dynamic styling based on goal state
    final Color mainColor = isOverspent 
        ? AppColors.expense 
        : (hasReachedGoal ? AppColors.primary : AppColors.income);
    final Color trackColor = isDark 
        ? mainColor.withOpacity(0.1) 
        : mainColor.withOpacity(0.05);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 350;
        final responsiveRadius = isSmall ? 40.0 : 55.0;
        final responsiveLineWidth = isSmall ? 10.0 : 12.0;
        final responsiveSpacing = isSmall ? 12.0 : 24.0;
        final responsiveGlowSize = isSmall ? 90.0 : 120.0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side: The iOS-style Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glowing effect background
                  Container(
                    width: responsiveGlowSize,
                    height: responsiveGlowSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: mainColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: responsiveRadius,
                    lineWidth: responsiveLineWidth,
                    percent: progress,
                    animation: true,
                    animateFromLastPercent: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: mainColor,
                    backgroundColor: trackColor,
                    center: _buildCenterContent(context, isSmall),
                  ),
                ],
              ),
              SizedBox(width: responsiveSpacing),
              // Right side: Refined Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SAVINGS PROGRESS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            letterSpacing: 1.5,
                            fontSize: isSmall ? 9 : 11,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Saved ${currencyFormatter.format(currentSavings)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: isSmall ? 16 : 18,
                              color: isOverspent ? AppColors.expense : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Target: ${currencyFormatter.format(targetSavings)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary.withOpacity(0.6) : AppColors.lightTextSecondary.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                            fontSize: isSmall ? 10 : 11,
                          ),
                    ),
                    if (hasReachedGoal || isOverspent) ...[
                      const SizedBox(height: 12),
                      _buildStatusChip(
                        hasReachedGoal ? 'Goal Met' : 'Overspent', 
                        hasReachedGoal ? AppColors.primary : AppColors.expense,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterContent(BuildContext context, bool isSmall) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (hasReachedGoal) {
      return Text(
        '🎉',
        style: TextStyle(fontSize: isSmall ? 18 : 24),
      );
    } else if (isOverspent) {
      return Icon(
        Icons.warning_amber_rounded, 
        color: AppColors.expense, 
        size: isSmall ? 22 : 28,
      );
    } else {
      return Text(
        '${(progress * 100).toInt()}%',
        style: TextStyle(
          fontSize: isSmall ? 16 : 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      );
    }
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
