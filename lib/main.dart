import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/database/app_database.dart';
import 'features/transactions/providers/transaction_providers.dart';
import 'package:finsight/features/profile/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Database
  final database = await AppDatabase.instance.database;

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
      ],
      child: const FlowApp(),
    ),
  );
}

class FlowApp extends ConsumerWidget {
  const FlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsAsync = ref.watch(profileSettingsNotifierProvider);
    final themeMode = settingsAsync.maybeWhen(
      data: (s) => s.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Flow - Personal Finance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
