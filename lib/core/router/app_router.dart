import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/lock_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/transactions/presentation/transaction_list_screen.dart';
import '../../features/transactions/presentation/add_edit_transaction_screen.dart';
import '../../features/transactions/domain/models/transaction_model.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorDashboardKey = GlobalKey<NavigatorState>();
final _shellNavigatorTransactionsKey = GlobalKey<NavigatorState>();
final _shellNavigatorInsightsKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/lock',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.uri.queryParameters['id'];
          return AddEditTransactionScreen(
            initialTransaction: state.extra as TransactionModel?,
            initialTransactionId: id,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorTransactionsKey,
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorInsightsKey,
            routes: [
              GoRoute(
                path: '/insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
