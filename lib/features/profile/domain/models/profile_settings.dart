import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_settings.freezed.dart';
part 'profile_settings.g.dart';

@freezed
class ProfileSettings with _$ProfileSettings {
  const factory ProfileSettings({
    @Default(2500.0) double dailySpendingLimit,
    @Default(5000.0) double monthlySavingsTarget,
    @Default(12) int streakTargetDays,
    @Default('INR') String currencyCode,
    @Default('₹') String currencySymbol,
    @Default(false) bool isDarkMode,
    @Default(false) bool isBiometricEnabled,
  }) = _ProfileSettings;

  factory ProfileSettings.fromJson(Map<String, dynamic> json) =>
      _$ProfileSettingsFromJson(json);
}
