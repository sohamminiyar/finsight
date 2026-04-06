import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../data/repositories/sqlite_settings_repository.dart';
import '../domain/models/profile_settings.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../../transactions/providers/transaction_providers.dart';

part 'settings_provider.g.dart';

@Riverpod(keepAlive: true)
ISettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqliteSettingsRepository(db);
}

@Riverpod(keepAlive: true)
class ProfileSettingsNotifier extends _$ProfileSettingsNotifier {
  static const String _settingsKey = 'profile_settings';

  @override
  Future<ProfileSettings> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    final jsonString = await repository.get(_settingsKey);
    
    if (jsonString != null) {
      try {
        return ProfileSettings.fromJson(jsonDecode(jsonString));
      } catch (e) {
        // Fallback to default if parsing fails
        return const ProfileSettings();
      }
    }
    return const ProfileSettings();
  }

  Future<void> updateSettings(ProfileSettings newSettings) async {
    state = AsyncValue.data(newSettings);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.set(_settingsKey, jsonEncode(newSettings.toJson()));
  }

  Future<void> setUserName(String name) async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(userName: name));
  }

  Future<void> setDailySpendingLimit(double limit) async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(dailySpendingLimit: limit));
  }

  Future<void> setStreakTargetDays(int days) async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(streakTargetDays: days));
  }

  Future<void> setMonthlySavingsTarget(double target) async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(monthlySavingsTarget: target));
  }

  Future<void> toggleTheme() async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(isDarkMode: !current.isDarkMode));
  }

  Future<void> updateCurrency(String code, String symbol) async {
    final current = state.value ?? const ProfileSettings();
    await updateSettings(current.copyWith(
      currencyCode: code,
      currencySymbol: symbol,
    ));
  }
  
  Future<void> resetToDefaults() async {
    const defaults = ProfileSettings();
    await updateSettings(defaults);
  }
}
