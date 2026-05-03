import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Card réutilisable avec bordure et fond blanc
class HezaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const HezaCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.cardBackground,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.divider),
          ),
          padding: padding ?? const EdgeInsets.all(AppTheme.paddingPage),
          child: child,
        ),
      ),
    );
  }
}

/// Badge/pill coloré (niveau de leçon, catégorie, etc.)
class HezaBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const HezaBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.primaryLight,
    this.textColor = AppColors.primary,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Barre de progression colorée avec label
class HezaProgressBar extends StatelessWidget {
  final double value; // 0.0 à 1.0
  final Color color;
  final double height;
  final Color? backgroundColor;

  const HezaProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: backgroundColor ?? AppColors.divider,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Widget "état vide" illustré avec icône et message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(icon, size: 40, color: AppColors.action),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Bouton d'action rapide circulaire (Home screen)
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textOnPrimary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Séparateur de section avec titre
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.headlineSmall),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.action,
              ),
            ),
          ),
      ],
    );
  }
}

/// Icône de catégorie avec fond coloré
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forCategory(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        _iconForCategory(category),
        color: color,
        size: size * 0.5,
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'transport': return Icons.directions_bus_rounded;
      case 'food':
      case 'alimentation': return Icons.restaurant_rounded;
      case 'loyer': return Icons.home_rounded;
      case 'charges': return Icons.bolt_rounded;
      case 'epargne':
      case 'épargne': return Icons.savings_rounded;
      case 'revenu':
      case 'income': return Icons.trending_up_rounded;
      default: return Icons.category_rounded;
    }
  }
}
