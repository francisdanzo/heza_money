import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_components.dart';
import '../../data/database/app_database.dart';
import '../../features/home/home_screen.dart';
import '../../features/budget/budget_screen.dart';
import '../../features/invest/invest_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/goals/add_goal_screen.dart';
import '../../features/budget/add_transaction_screen.dart';
import '../../features/invest/lesson_detail_screen.dart';
import '../../features/gamification/badges_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/accounts/accounts_screen.dart';
import '../../features/accounts/add_account_screen.dart';
import '../../shared/widgets/main_shell.dart';

CustomTransitionPage<void> _slideUpPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, _, child) {
      final tween = Tween(begin: const Offset(0, 1), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

CustomTransitionPage<void> _slideRightPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, _, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

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
  static const String home        = '/';
  static const String budget      = '/budget';
  static const String invest      = '/invest';
  static const String profile     = '/profile';
  static const String accounts    = '/accounts';
  static const String goals       = '/goals';
  static const String addGoal     = '/goals/add';
  static const String addTransaction = '/budget/add';
  static const String lessonDetail   = '/invest/lesson/:id';
  static const String badges      = '/badges';
  static const String onboarding  = '/onboarding';
  static const String addAccount  = '/accounts/add';
  static const String accountDetail = '/accounts/:id';

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
            path: accounts,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AccountsScreen(),
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
        pageBuilder: (context, state) => _slideUpPage(state, const GoalsScreen()),
      ),
      GoRoute(
        path: addGoal,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final goal = state.extra as Goal?;
          return _slideUpPage(state, AddGoalScreen(goal: goal));
        },
      ),
      GoRoute(
        path: addTransaction,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final type        = state.uri.queryParameters['type'] ?? 'expense';
          final transaction = state.extra as Transaction?;
          return _slideUpPage(state, AddTransactionScreen(initialType: type, transaction: transaction));
        },
      ),
      GoRoute(
        path: lessonDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '01';
          return _slideRightPage(state, LessonDetailScreen(lessonId: id));
        },
      ),
      GoRoute(
        path: badges,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideRightPage(state, const BadgesScreen()),
      ),
      GoRoute(
        path: onboarding,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideUpPage(state, const OnboardingScreen()),
      ),
      GoRoute(
        path: addAccount,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final account = state.extra as Account?;
          return _slideUpPage(state, AddAccountScreen(account: account));
        },
      ),
      GoRoute(
        path: accountDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          return _slideRightPage(state, _AccountDetailPlaceholder(accountId: id));
        },
      ),
    ],
  );
}

// Placeholder simple pour account detail — expand later
class _AccountDetailPlaceholder extends ConsumerWidget {
  final int? accountId;
  const _AccountDetailPlaceholder({this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: GlassAppBar(
        title: 'Détails du compte',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text('Bientôt disponible',
            style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.grey)),
      ),
    );
  }
}
