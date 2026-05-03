import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/invest/invest_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/goals/add_goal_screen.dart';
import '../../features/budget/add_transaction_screen.dart';
import '../../features/invest/lesson_detail_screen.dart';
import '../../features/gamification/badges_screen.dart';
import '../../shared/widgets/main_shell.dart';

/// Configuration du routeur go_router pour Heza Money
/// La navigation principale utilise un shell avec BottomNavigationBar
class AppRouter {
  AppRouter._();

  // --- Clés de navigation ---
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // --- Noms des routes ---
  static const String home = '/';
  static const String budget = '/budget';
  static const String invest = '/invest';
  static const String profile = '/profile';
  static const String goals = '/goals';
  static const String addGoal = '/goals/add';
  static const String addTransaction = '/budget/add';
  static const String lessonDetail = '/invest/lesson/:id';
  static const String badges = '/badges';

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    debugLogDiagnostics: false,
    routes: [
      // Shell route — englobe les 4 onglets principaux avec la BottomNavBar
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: budget,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BudgetScreen(),
            ),
          ),
          GoRoute(
            path: invest,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InvestScreen(),
            ),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Routes modales — au-dessus du shell, sans BottomNavBar
      GoRoute(
        path: goals,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: addGoal,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddGoalScreen(),
      ),
      GoRoute(
        path: addTransaction,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          return AddTransactionScreen(initialType: type);
        },
      ),
      GoRoute(
        path: lessonDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '01';
          return LessonDetailScreen(lessonId: id);
        },
      ),
      GoRoute(
        path: badges,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BadgesScreen(),
      ),
    ],
  );
}
