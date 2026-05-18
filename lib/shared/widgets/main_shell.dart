import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Shell principal — enveloppe les 4 onglets avec la BottomNavigationBar
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  // Retourne l'index actif selon la route courante
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/budget')) return 1;
    if (location.startsWith('/invest')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // home
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/budget');
      case 2:
        context.go('/invest');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => _onTap(context, i),
          items: [
            _navItem(icon: _NavIcon.home, label: 'Accueil', active: currentIndex == 0),
            _navItem(icon: _NavIcon.budget, label: 'Budget', active: currentIndex == 1),
            _navItem(icon: _NavIcon.invest, label: 'Investir', active: currentIndex == 2),
            _navItem(icon: _NavIcon.profile, label: 'Profil', active: currentIndex == 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required String icon,
    required String label,
    required bool active,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(
          _iconData(icon),
          size: 22,
          color: active ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
      label: label,
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case _NavIcon.home: return Icons.home_rounded;
      case _NavIcon.budget: return Icons.account_balance_wallet_rounded;
      case _NavIcon.invest: return Icons.school_rounded;
      case _NavIcon.profile: return Icons.person_rounded;
      default: return Icons.circle;
    }
  }
}

class _NavIcon {
  static const home = 'home';
  static const budget = 'budget';
  static const invest = 'invest';
  static const profile = 'profile';
}
