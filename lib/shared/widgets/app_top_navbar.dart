import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/dashboard/presentation/widgets/streak_widget.dart';
import '../../features/dashboard/providers/alert_provider.dart';
import '../../features/dashboard/presentation/widgets/notification_bottom_sheet.dart';

class AppTopNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final int? streakDays;
  final VoidCallback? onSettingsPressed;

  const AppTopNavbar({
    super.key,
    this.title = 'Flow',
    this.showBack = false,
    this.streakDays,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final hPadding = screenSize.width * 0.06;
    final badgeSize = (screenSize.width * 0.02).clamp(6.0, 10.0);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 50,
      leadingWidth: hPadding + 50,
      leading: Padding(
        padding: EdgeInsets.only(left: hPadding),
        child: showBack
            ? IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  size: 20,
                ),
              )
            : IconButton(
                onPressed: () => context.push('/profile'),
                icon: const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                ),
              ),
      ),
      titleSpacing: 0,
      title: Text(
        'Flow',
        style: AppTextStyles.headlineSmall(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (streakDays != null) ...[
          StreakWidget(
            streakDays: streakDays!,
            isActive: true,
          ),
          const SizedBox(width: 8),
        ],
        Consumer(
          builder: (context, ref, child) {
            final alerts = ref.watch(smartAlertsProvider);
            return Badge(
              isLabelVisible: alerts.isNotEmpty,
              backgroundColor: AppColors.expense,
              smallSize: badgeSize,
              offset: const Offset(-2, 2),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const NotificationBottomSheet(),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.grey),
                tooltip: 'Notifications',
              ),
            );
          },
        ),
        SizedBox(width: hPadding),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

/// A Sliver version of the AppTopNavbar for use in CustomScrollViews
class SliverAppTopNavbar extends ConsumerWidget {
  final String title;
  final bool showBack;
  final int? streakDays;
  final VoidCallback? onSettingsPressed;

  const SliverAppTopNavbar({
    super.key,
    this.title = 'Flow',
    this.showBack = false,
    this.streakDays,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);
    final hPadding = screenSize.width * 0.06;
    final badgeSize = (screenSize.width * 0.02).clamp(6.0, 10.0);

    return SliverAppBar(
      toolbarHeight: 50,
      floating: true,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.lightScaffold,
      leadingWidth: hPadding + 50,
      leading: Padding(
        padding: EdgeInsets.only(left: hPadding),
        child: showBack
            ? IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  size: 20,
                ),
              )
            : IconButton(
                onPressed: () => context.push('/profile'),
                icon: const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                ),
              ),
      ),
      titleSpacing: 0,
      title: Text(
        'Flow',
        style: AppTextStyles.headlineSmall(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        if (streakDays != null) ...[
          StreakWidget(
            streakDays: streakDays!,
            isActive: true,
          ),
          const SizedBox(width: 8),
        ],
        Consumer(
          builder: (context, ref, child) {
            final alerts = ref.watch(smartAlertsProvider);
            return Badge(
              isLabelVisible: alerts.isNotEmpty,
              backgroundColor: AppColors.expense,
              smallSize: badgeSize,
              offset: const Offset(-2, 2),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const NotificationBottomSheet(),
                  );
                },
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.grey),
                tooltip: 'Notifications',
              ),
            );
          },
        ),
        SizedBox(width: hPadding),
      ],
    );
  }
}
