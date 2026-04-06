import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final AppButtonType type;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return _buildPrimary(context);
      case AppButtonType.secondary:
        return _buildSecondary(context);
      case AppButtonType.ghost:
        return _buildGhost(context);
    }
  }

  Widget _buildPrimary(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9999),
        gradient: LinearPaul(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(9999),
          child: Padding(
            padding: const Offset(0, 16).vertical,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: AppTextStyles.labelLarge(context).copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.glassBackgroundDark
                : AppColors.glassBackgroundLight,
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(9999),
              child: Padding(
                padding: const Offset(0, 16).vertical,
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhost(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelLarge(context).copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

extension on Offset {
  EdgeInsets get vertical => EdgeInsets.symmetric(vertical: dy);
}

class LinearPaul extends LinearGradient {
  const LinearPaul({
    required super.colors,
    super.begin,
    super.end,
  });
}
