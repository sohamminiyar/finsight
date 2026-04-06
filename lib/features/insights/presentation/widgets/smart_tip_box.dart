import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SmartTipBox extends StatelessWidget {
  final String tip;

  const SmartTipBox({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F25) : const Color(0xFFEDF4F8),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF0D47A1),
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: isDark ? AppColors.darkTextPrimary : const Color(0xFF334155),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Smart Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.primary : const Color(0xFF0D47A1),
                    ),
                  ),
                  TextSpan(text: tip),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
