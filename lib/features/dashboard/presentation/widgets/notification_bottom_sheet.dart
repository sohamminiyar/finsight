import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/smart_alert.dart';
import '../../providers/alert_provider.dart';

class NotificationBottomSheet extends ConsumerWidget {
  const NotificationBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(smartAlertsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // 75% of screen height
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Smart Feed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 24),
          if (alerts.isEmpty)
            Expanded(child: _buildEmptyState(context, isDark))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                itemCount: alerts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return _buildAlertCard(context, alert, isDark);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, SmartAlert alert, bool isDark) {
    final Color iconColor = _getAlertColor(alert.type);
    final IconData iconData = _getAlertIcon(alert.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.notifications_off_outlined,
          size: 64,
          color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary).withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'You are all caught up!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Check back later for new alerts.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkTextSecondary.withOpacity(0.7) : AppColors.lightTextSecondary.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return AppColors.expense;
      case AlertType.success:
        return AppColors.primary;
      case AlertType.info:
        return AppColors.income; // Sky Blue
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.warning:
        return Icons.warning_amber_rounded;
      case AlertType.success:
        return Icons.check_circle_outline_rounded;
      case AlertType.info:
        return Icons.info_outline_rounded;
    }
  }
}
