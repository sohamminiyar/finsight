// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileSettingsImpl _$$ProfileSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileSettingsImpl(
  dailySpendingLimit:
      (json['dailySpendingLimit'] as num?)?.toDouble() ?? 2500.0,
  monthlySavingsTarget:
      (json['monthlySavingsTarget'] as num?)?.toDouble() ?? 5000.0,
  streakTargetDays: (json['streakTargetDays'] as num?)?.toInt() ?? 12,
  currencyCode: json['currencyCode'] as String? ?? 'INR',
  currencySymbol: json['currencySymbol'] as String? ?? '₹',
  isDarkMode: json['isDarkMode'] as bool? ?? false,
  isBiometricEnabled: json['isBiometricEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$$ProfileSettingsImplToJson(
  _$ProfileSettingsImpl instance,
) => <String, dynamic>{
  'dailySpendingLimit': instance.dailySpendingLimit,
  'monthlySavingsTarget': instance.monthlySavingsTarget,
  'streakTargetDays': instance.streakTargetDays,
  'currencyCode': instance.currencyCode,
  'currencySymbol': instance.currencySymbol,
  'isDarkMode': instance.isDarkMode,
  'isBiometricEnabled': instance.isBiometricEnabled,
};
