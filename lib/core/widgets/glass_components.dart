import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

// ─── GLASS CARD ──────────────────────────────────────────────────────────────
/// Card glassmorphique avec backdrop blur.
/// Utiliser pour toutes les cartes de contenu (stats, listes, forms, etc.)
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? opacity;
  final EdgeInsets padding;
  final double radius;
  final Border? border;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final Color? tintColor;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = HezaBlur.normal,
    this.opacity,
    this.padding = const EdgeInsets.all(HezaSpacing.lg),
    this.radius = HezaRadius.lg,
    this.border,
    this.shadows,
    this.onTap,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final effectiveOpacity = opacity ?? t.glassOpacity;
    final effectiveBg = (tintColor ?? t.glassBg).withValues(alpha: effectiveOpacity);

    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBg,
            border: border ?? Border.all(color: t.glassBorder, width: 1),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: shadows ?? t.shadowMd,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap == null) return inner;

    return _PressableWrapper(onTap: onTap!, child: inner);
  }
}

// ─── GLASS APP BAR ───────────────────────────────────────────────────────────
/// AppBar glassmorphique avec gradient vert Heza.
/// Remplace AppBar dans tous les écrans avec header vert.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showGradient;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showGradient = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = showGradient
        ? null
        : (isDark ? HezaColors.darkBg : HezaColors.lightBg);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: HezaBlur.strong, sigmaY: HezaBlur.strong),
        child: Container(
          decoration: BoxDecoration(
            gradient: showGradient
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [HezaColors.darkBg2, HezaColors.darkSurface]
                        : [HezaColors.primary, HezaColors.primaryLight],
                  )
                : null,
            color: bg,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? HezaColors.darkBorder
                    : HezaColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: showGradient
                        ? Colors.white
                        : (isDark ? HezaColors.darkText : HezaColors.lightText),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: showGradient
                          ? Colors.white.withValues(alpha: 0.75)
                          : (isDark ? HezaColors.darkTextSub : HezaColors.lightTextSub),
                    ),
                  ),
              ],
            ),
            leading: leading,
            actions: actions,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ─── GLASS BOTTOM NAV ────────────────────────────────────────────────────────
/// BottomNavigationBar glassmorphique avec backdrop blur.
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: HezaBlur.strong, sigmaY: HezaBlur.strong),
        child: Container(
          decoration: BoxDecoration(
            color: t.glassBg.withValues(alpha: t.isDark ? 0.85 : 0.92),
            border: Border(
              top: BorderSide(color: t.glassBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 56,
              child: Row(
                children: List.generate(items.length, (i) {
                  final active = i == currentIndex;
                  final item = items[i];
                  return Expanded(
                    child: _GlassNavTile(
                      icon: item.icon,
                      activeIcon: item.activeIcon ?? item.icon,
                      label: item.label,
                      active: active,
                      onTap: () => onTap(i),
                      activeColor: t.primary,
                      inactiveColor: t.textSub,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  const GlassNavItem({required this.icon, this.activeIcon, required this.label});
}

class _GlassNavTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _GlassNavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: active ? 16 : 0,
                vertical: 2,
              ),
              decoration: active
                  ? BoxDecoration(
                      color: activeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(HezaRadius.full),
                    )
                  : null,
              child: Icon(
                active ? activeIcon : icon,
                size: 22,
                color: active ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GLASS BUTTON ────────────────────────────────────────────────────────────
/// Bouton principal glassmorphique avec press feedback (scale + opacity).
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? textColor;
  final double radius;
  final EdgeInsets padding;
  final IconData? leadingIcon;
  final bool fullWidth;

  const GlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.radius = HezaRadius.md,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.leadingIcon,
    this.fullWidth = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    final bg = widget.color ?? t.primary;
    final fg = widget.textColor ?? Colors.white;
    final disabled = widget.onPressed == null || widget.isLoading;

    Widget content = Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        else ...[
          if (widget.leadingIcon != null) ...[
            Icon(widget.leadingIcon, size: 18, color: fg),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ],
    );

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => _ctrl.forward(),
        onTapUp: disabled ? null : (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onPressed == null ? null : () {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        },
        child: AnimatedOpacity(
          opacity: disabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: bg.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

// ─── GLASS INPUT ─────────────────────────────────────────────────────────────
/// Champ de saisie glassmorphique avec blur et bordure verte.
class GlassInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final FocusNode? focusNode;
  final int maxLines;

  const GlassInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: t.textSub,
            ),
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(HezaRadius.md),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: HezaBlur.subtle, sigmaY: HezaBlur.subtle),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              obscureText: obscureText,
              focusNode: focusNode,
              maxLines: maxLines,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: t.text,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: t.textMuted,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: t.glassBg.withValues(alpha: t.isDark ? 0.5 : 0.85),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                  borderSide: BorderSide(color: t.glassBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                  borderSide: BorderSide(color: t.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                  borderSide: const BorderSide(color: HezaColors.error, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                  borderSide: const BorderSide(color: HezaColors.error, width: 1.5),
                ),
                errorText: errorText,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── GLASS GRADIENT HEADER ───────────────────────────────────────────────────
/// Fond gradient vert pour le header de l'écran Home.
class GlassGradientHeader extends StatelessWidget {
  final Widget child;
  final double blurAmount;

  const GlassGradientHeader({
    super.key,
    required this.child,
    this.blurAmount = HezaBlur.subtle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [HezaColors.darkBg2, const Color(0xFF1A3526)]
              : [HezaColors.primary, HezaColors.primaryLight],
        ),
      ),
      child: child,
    );
  }
}

// ─── GLASS STAT CARD ─────────────────────────────────────────────────────────
/// Carte de statistique avec icône et valeur — utilisée pour les stats sur Home.
class GlassStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const GlassStatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final t = HezaTheme.of(context);
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(HezaRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: t.textSub,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor ?? t.text,
              letterSpacing: -0.3,
            ),
          ),
          if (unit != null)
            Text(
              unit!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: t.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── PRESSABLE WRAPPER ───────────────────────────────────────────────────────
/// Scale feedback au tap — wraps n'importe quel widget.
class _PressableWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableWrapper({required this.child, required this.onTap});

  @override
  State<_PressableWrapper> createState() => _PressableWrapperState();
}

class _PressableWrapperState extends State<_PressableWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
