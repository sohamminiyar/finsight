import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'streak_stats_popover.dart';
import '../../providers/dashboard_provider.dart';
import '../../../profile/providers/settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StreakWidget extends StatefulWidget {
  final int streakDays;
  final bool isActive;
  const StreakWidget({super.key, required this.streakDays, this.isActive = true});

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }
  
  @override
  void didUpdateWidget(StreakWidget oldWidget) {
    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showStatsPopover({
    required BuildContext context,
    required WidgetRef ref,
    required int streakDays,
  }) {
    final summaryAsync = ref.read(dashboardSummaryProvider);
    final settingsAsync = ref.read(profileSettingsNotifierProvider);

    final summary = summaryAsync.asData?.value;
    final settings = settingsAsync.asData?.value;

    if (summary == null || settings == null) return;

    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      barrierDismissible: true,
      barrierLabel: 'Close',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, _, __) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 70.0, right: 16.0),
            child: StreakStatsPopover(
              currentStreak: summary.streakDays,
              todayExpenses: summary.todayExpenses,
              dailyLimit: settings.dailySpendingLimit,
              currencySymbol: settings.currencySymbol,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return GestureDetector(
          onTap: () => _showStatsPopover(
            context: context,
            ref: ref,
            streakDays: widget.streakDays,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED), // Light Orange (Orange 50)
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF97316).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFF97316), // Orange 500
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.streakDays} Days',
                  style: AppTextStyles.labelLarge(context).copyWith(
                    color: const Color(0xFFF97316), // Orange 500
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

