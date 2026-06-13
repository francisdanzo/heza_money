import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

// ─── HEZA CARD ───────────────────────────────────────────────────────────────
/// Card glassmorphique réutilisable (wrapper autour de GlassCard pour compatibilité)
class HezaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double? radius;

  const HezaCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final effectiveRadius = radius ?? HezaRadius.lg;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(effectiveRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: HezaBlur.normal, sigmaY: HezaBlur.normal),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? t.glassBg).withValues(alpha: t.glassOpacity),
            border: Border.all(color: t.glassBorder, width: 1),
            borderRadius: BorderRadius.circular(effectiveRadius),
            boxShadow: t.shadowMd,
          ),
          padding: padding ?? const EdgeInsets.all(HezaSpacing.lg),
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;
    return _PressWrapper(onTap: onTap!, child: card);
  }
}

// ─── HEZA BADGE ──────────────────────────────────────────────────────────────
class HezaBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const HezaBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? t.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HezaRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? t.primary,
        ),
      ),
    );
  }
}

// ─── HEZA PROGRESS BAR ───────────────────────────────────────────────────────
/// Progress bar personnalisée avec gradient et glow en dark mode.
class HezaProgressBar extends StatelessWidget {
  final double value;
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
    final t = HezaTheme.of(context);
    final clamped = value.clamp(0.0, 1.0);
    final bg = backgroundColor ?? color.withValues(alpha: t.isDark ? 0.15 : 0.08);

    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.maxWidth * clamped;
        return SizedBox(
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(HezaRadius.full),
            child: Stack(
              children: [
                // Piste de fond
                Positioned.fill(child: Container(color: bg)),
                // Remplissage avec gradient + glow
                if (clamped > 0)
                  Positioned(
                    left: 0, top: 0, bottom: 0,
                    width: fillWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.75),
                            color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(HezaRadius.full),
                        boxShadow: t.isDark
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.50),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── EMPTY STATE ─────────────────────────────────────────────────────────────
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
    final t = HezaTheme.of(context);
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
                color: t.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(icon, size: 40, color: t.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: t.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: t.textSub,
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

// ─── QUICK ACTION BUTTON ─────────────────────────────────────────────────────
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
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return _PressWrapper(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(HezaRadius.lg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: HezaBlur.normal, sigmaY: HezaBlur.normal),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: t.isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundColor.withValues(alpha: 0.22),
                            backgroundColor.withValues(alpha: 0.12),
                          ],
                        )
                      : null,
                  color: t.isDark ? null : backgroundColor.withValues(alpha: 0.88),
                  border: Border.all(
                    color: backgroundColor.withValues(alpha: t.isDark ? 0.28 : 0.35),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(HezaRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: t.isDark ? 0.18 : 0.28),
                      blurRadius: t.isDark ? 14 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: t.isDark ? backgroundColor : iconColor,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: t.textSub,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── SECTION HEADER ──────────────────────────────────────────────────────────
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
    final t = HezaTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              actionLabel!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: t.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── CATEGORY ICON ───────────────────────────────────────────────────────────
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = HezaColors.forCategory(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Icon(
        _iconForCategory(category),
        color: color,
        size: size * 0.45,
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'transport':              return Icons.directions_bus_rounded;
      case 'food':
      case 'alimentation':           return Icons.restaurant_rounded;
      case 'loyer':                  return Icons.home_rounded;
      case 'charges':                return Icons.bolt_rounded;
      case 'epargne':
      case 'épargne':                return Icons.savings_rounded;
      case 'revenu':
      case 'income':                 return Icons.trending_up_rounded;
      default:                       return Icons.category_rounded;
    }
  }
}

// ─── PRESS WRAPPER ───────────────────────────────────────────────────────────
class _PressWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressWrapper({required this.child, required this.onTap});

  @override
  State<_PressWrapper> createState() => _PressWrapperState();
}

class _PressWrapperState extends State<_PressWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}
