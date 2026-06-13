import 'dart:math' show max;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

// ─── GLASS CARD ──────────────────────────────────────────────────────────────
/// Card glassmorphique premium avec top-edge highlight en dark mode.
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

    // Top-edge highlight border pour dark mode (effet lumière sur bord supérieur)
    final effectiveBorder = border ?? (t.isDark
        ? Border(
            top:    BorderSide(color: t.glassTopEdge,  width: 0.8),
            left:   BorderSide(color: t.glassBorder,   width: 0.5),
            right:  BorderSide(color: t.glassBorder,   width: 0.5),
            bottom: BorderSide(color: t.glassBorder,   width: 0.5),
          )
        : Border.all(color: t.glassBorder, width: 1));

    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBg,
            border: effectiveBorder,
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
    final bg = showGradient ? null
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
                        ? [HezaColors.darkBg, HezaColors.darkBg2]
                        : [HezaColors.primary, HezaColors.primaryLight.withValues(alpha: 0.8)],
                  )
                : null,
            color: bg,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? HezaColors.glassHairline
                    : HezaColors.primary.withValues(alpha: 0.2),
                width: 0.5,
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
                    color: showGradient ? Colors.white
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
                          ? Colors.white.withValues(alpha: 0.7)
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

// ─── GLASS BOTTOM NAV — Floating Island Style ────────────────────────────────
/// Navbar flottante en forme d'île pilule — ne touche pas les bords de l'écran.
/// Effet glassmorphique, limelight vert sur item actif, glow vert en dark mode.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final islandHeight = 64.0;
    final topGap = 10.0;
    final bottomGap = max(safeBottom > 0 ? safeBottom - 4 : 10.0, 10.0);

    return Container(
      color: Colors.transparent,
      height: topGap + islandHeight + bottomGap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, topGap, 18, bottomGap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: HezaBlur.overlay, sigmaY: HezaBlur.overlay),
            child: Container(
              height: islandHeight,
              decoration: BoxDecoration(
                color: isDark
                    ? HezaColors.darkBg2.withValues(alpha: 0.93)
                    : HezaColors.lightSurface.withValues(alpha: 0.97),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: isDark
                      ? const Color(0x1AFFFFFF)
                      : HezaColors.lightBorder,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                  if (isDark)
                    BoxShadow(
                      color: HezaColors.primaryLight.withValues(alpha: 0.09),
                      blurRadius: 50,
                      spreadRadius: 6,
                    ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: _LimelightNavTile(
                      icon: items[i].icon,
                      activeIcon: items[i].activeIcon ?? items[i].icon,
                      label: items[i].label,
                      active: i == currentIndex,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTap(i);
                      },
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

class _LimelightNavTile extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _LimelightNavTile({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor  = isDark ? HezaColors.primaryLight : HezaColors.primary;
    final inactiveColor = isDark ? HezaColors.darkTextMuted : HezaColors.lightTextMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Limelight indicator (ligne verte avec glow en haut) ───────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 3,
            width: active ? 28 : 0,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.65),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),

          // ── Icône avec halo actif ─────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: active ? 44 : 28,
            height: 28,
            decoration: active ? BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  activeColor.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ) : null,
            child: Center(
              child: Icon(
                active ? activeIcon : icon,
                size: 22,
                color: active ? activeColor : inactiveColor,
              ),
            ),
          ),

          const SizedBox(height: 2),

          // ── Label ─────────────────────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? activeColor : inactiveColor,
            ),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ─── GLASS GRADIENT HEADER ───────────────────────────────────────────────────
/// Header avec gradient premium.
/// Light mode : gradient vert Heza.
/// Dark mode  : deep navy-black avec ambient blobs verts/bleus (cinematic dark).
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

    // Aurora animée dans les deux modes — blobs adaptés à chaque fond
    return ClipRect(
      child: AuroraBackground(
        isDark: isDark,
        child: Stack(
          children: [
            // ── Accent ligne horizontale en bas ──────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 0.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: isDark ? 0.30 : 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // ── Contenu ───────────────────────────────────────────────────────
            child,
          ],
        ),
      ),
    );
  }
}

// ─── GLASS BUTTON ────────────────────────────────────────────────────────────
/// Bouton principal avec gradient en dark mode et glow vert.
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
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
            width: 18, height: 18,
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
          opacity: disabled ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              // Dark mode : gradient vert / Light mode : couleur unie
              gradient: t.isDark && widget.color == null
                  ? const LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: t.isDark && widget.color == null ? null : bg,
              borderRadius: BorderRadius.circular(widget.radius),
              boxShadow: [
                BoxShadow(
                  color: bg.withValues(alpha: t.isDark ? 0.45 : 0.30),
                  blurRadius: t.isDark ? 20 : 12,
                  offset: const Offset(0, 5),
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
              style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: t.text),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 15, color: t.textMuted),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                filled: true,
                fillColor: t.glassBg.withValues(alpha: t.isDark ? 0.6 : 0.85),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(HezaRadius.md),
                  borderSide: BorderSide(color: t.glassBorder, width: 0.8),
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

// ─── GLASS STAT CARD ─────────────────────────────────────────────────────────
/// Carte statistique avec accent indicator.
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(HezaRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: HezaBlur.normal, sigmaY: HezaBlur.normal),
        child: Container(
          decoration: BoxDecoration(
            color: t.glassBg.withValues(alpha: t.glassOpacity),
            borderRadius: BorderRadius.circular(HezaRadius.lg),
            border: t.isDark
                ? Border(
                    top:    BorderSide(color: t.glassTopEdge, width: 0.8),
                    left:   BorderSide(color: t.glassBorder,  width: 0.5),
                    right:  BorderSide(color: t.glassBorder,  width: 0.5),
                    bottom: BorderSide(color: t.glassBorder,  width: 0.5),
                  )
                : Border.all(color: t.glassBorder, width: 1),
            boxShadow: t.shadowMd,
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barre accent colorée à gauche avec glow
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: iconColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(HezaRadius.lg),
                      bottomLeft: Radius.circular(HezaRadius.lg),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.45),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Contenu
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    iconColor.withValues(alpha: t.isDark ? 0.22 : 0.12),
                                    iconColor.withValues(alpha: 0.03),
                                  ],
                                ),
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
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: t.textSub,
                                  letterSpacing: 0.1,
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
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: valueColor ?? t.text,
                            letterSpacing: -0.5,
                            shadows: t.isDark
                                ? [Shadow(
                                    color: (valueColor ?? iconColor).withValues(alpha: 0.35),
                                    blurRadius: 12,
                                  )]
                                : null,
                          ),
                        ),
                        if (unit != null)
                          Text(
                            unit!,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: t.textMuted,
                              letterSpacing: 0.3,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── AURORA BACKGROUND ───────────────────────────────────────────────────────
/// Fond animé avec blobs radials qui respirent — effets aurora/ambiant.
/// À utiliser derrière les headers et cartes hero en dark mode.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  final bool isDark;
  const AuroraBackground({super.key, required this.child, this.isDark = true});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Fond de base
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isDark
                    ? const [Color(0xFF020617), Color(0xFF0B1628)]
                    : const [HezaColors.primary, Color(0xFF1D9E75)],
              ),
            ),
          ),
        ),
        // Blobs animés isolés dans un RepaintBoundary
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) {
                final t = _anim.value;
                if (widget.isDark) {
                  return Stack(children: [
                    // Blob vert — top-right
                    Positioned(
                      top: -80 + t * 25, right: -40 + t * 20,
                      child: _AuroraBlob(size: 300 + t * 60, color: HezaColors.primaryLight, opacity: 0.11 + t * 0.09),
                    ),
                    // Blob bleu — bottom-left
                    Positioned(
                      bottom: -40 - t * 15, left: -30 + t * 15,
                      child: _AuroraBlob(size: 220 - t * 30, color: const Color(0xFF3B82F6), opacity: 0.07 + t * 0.06),
                    ),
                    // Blob émeraude — centre
                    Positioned(
                      top: 40 + t * 40, right: 70 - t * 30,
                      child: _AuroraBlob(size: 150 + t * 40, color: const Color(0xFF10B981), opacity: 0.05 + t * 0.05),
                    ),
                  ]);
                } else {
                  // Light mode — blobs blancs et vert profond sur fond vert
                  return Stack(children: [
                    // Blob blanc — top-right, lumière naturelle
                    Positioned(
                      top: -70 + t * 20, right: -50 + t * 15,
                      child: _AuroraBlob(size: 280 + t * 50, color: Colors.white, opacity: 0.18 + t * 0.10),
                    ),
                    // Blob vert profond — bottom-left, profondeur
                    Positioned(
                      bottom: -50 - t * 10, left: -20 + t * 10,
                      child: _AuroraBlob(size: 200 - t * 20, color: const Color(0xFF064E3B), opacity: 0.20 + t * 0.12),
                    ),
                    // Blob doré — centre, chaleur
                    Positioned(
                      top: 50 + t * 30, right: 60 - t * 20,
                      child: _AuroraBlob(size: 140 + t * 30, color: const Color(0xFFFDE68A), opacity: 0.08 + t * 0.06),
                    ),
                  ]);
                }
              },
            ),
          ),
        ),
        // Étoiles/sparkles statiques — décoration subtile
        ..._buildSparkles(),
        // Contenu au-dessus
        widget.child,
      ],
    );
  }

  List<Widget> _buildSparkles() {
    const positions = [
      [58.0, 38.0], [204.0, 18.0], [318.0, 62.0],
      [82.0, 108.0], [248.0, 78.0], [152.0, 28.0],
    ];
    const sizes     = [2.0, 1.5, 2.0, 1.5, 2.5, 1.5];
    final opacities = widget.isDark
        ? const [0.35, 0.22, 0.38, 0.18, 0.28, 0.22]
        : const [0.45, 0.30, 0.50, 0.25, 0.38, 0.30];
    return List.generate(6, (i) => Positioned(
      left: positions[i][0],
      top:  positions[i][1],
      child: Container(
        width:  sizes[i],
        height: sizes[i],
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacities[i]),
          shape: BoxShape.circle,
        ),
      ),
    ));
  }
}

class _AuroraBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _AuroraBlob({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: opacity * 0.35),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// ─── PRESSABLE WRAPPER ───────────────────────────────────────────────────────
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
