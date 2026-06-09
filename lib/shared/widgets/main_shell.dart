import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_components.dart';

/// Shell principal avec BottomNavigationBar glassmorphique
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/budget'))   return 1;
    if (path.startsWith('/accounts')) return 2;
    if (path.startsWith('/invest'))   return 3;
    if (path.startsWith('/profile'))  return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/');
      case 1: context.go('/budget');
      case 2: context.go('/accounts');
      case 3: context.go('/invest');
      case 4: context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          GlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Accueil',
          ),
          GlassNavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: 'Budget',
          ),
          GlassNavItem(
            icon: Icons.credit_card_outlined,
            activeIcon: Icons.credit_card_rounded,
            label: 'Comptes',
          ),
          GlassNavItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school_rounded,
            label: 'Investir',
          ),
          GlassNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
