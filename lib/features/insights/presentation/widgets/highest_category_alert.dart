import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/insights_summary.dart';

class HighestCategoryAlert extends StatelessWidget {
  final CategorySpending category;

  const HighestCategoryAlert({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF3D1616), const Color(0xFF2D1212)]
              : [const Color(0xFFFFF1F1), const Color(0xFFFFEBEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: const Color(0xFFFF8A80).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              category.icon,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'ALERT',
            style: AppTextStyles.labelMedium(context).copyWith(
              color: Colors.red[900],
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Highest Spending Category: ${category.name}',
            style: AppTextStyles.headlineSmall(context).copyWith(
              color: const Color(0xFF910000),
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Impact',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: const Color(0xFFB71C1C).withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.percentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.headlineMedium(context).copyWith(
                      color: const Color(0xFFB71C1C),
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFB71C1C),
                size: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
