// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRepositoryHash() =>
    r'a768cc109237cfc24f18719db796e69e52c97707';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider = Provider<ISettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SettingsRepositoryRef = ProviderRef<ISettingsRepository>;
String _$profileSettingsNotifierHash() =>
    r'b6b71f8fa86c47c14dbb45a726416418de5cf8f9';

/// See also [ProfileSettingsNotifier].
@ProviderFor(ProfileSettingsNotifier)
final profileSettingsNotifierProvider =
    AsyncNotifierProvider<ProfileSettingsNotifier, ProfileSettings>.internal(
      ProfileSettingsNotifier.new,
      name: r'profileSettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileSettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileSettingsNotifier = AsyncNotifier<ProfileSettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
