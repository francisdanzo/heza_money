import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Composant GlassCard — Glassmorphism réutilisable avec backdrop blur
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderRadius;
  final double blurIntensity;
  final EdgeInsets padding;
  final List<BoxShadow>? shadows;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 16,
    this.blurIntensity = 15,
    this.padding = const EdgeInsets.all(16),
    this.shadows,
    this.border,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark: isDark);

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
        child: Container(
          decoration: BoxDecoration(
            color: (backgroundColor ?? colors.glassSurface)
                .withValues(alpha: isDark ? 0.4 : 0.8),
            border: border ??
                Border.all(
                  color: colors.border.withValues(alpha: isDark ? 0.2 : 0.1),
                  width: 1,
                ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: shadows ??
                (isDark
                    ? HezaShadows.darkGlassOuter
                    : HezaShadows.lightMd),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

/// GlassButton — Bouton glassmorphism avec feedback
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double blurIntensity;

  const GlassButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.blurIntensity = 15,
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isDisabled || widget.isLoading) return;
    _scaleController.forward();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark: isDark);

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.97).animate(_scaleController),
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: () {
          _scaleController.reverse();
          setState(() => _isPressed = false);
        },
        onTap: widget.isDisabled || widget.isLoading ? null : widget.onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurIntensity,
              sigmaY: widget.blurIntensity,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: (widget.backgroundColor ?? HezaColors.primaryLight)
                    .withValues(
                  alpha: widget.isDisabled ? 0.4 : (_isPressed ? 0.9 : 0.7),
                ),
                border: Border.all(
                  color: colors.border.withValues(alpha: isDark ? 0.2 : 0.1),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: (widget.backgroundColor ?? HezaColors.primaryLight)
                        .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding,
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor ?? Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.foregroundColor ?? Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// GlassGradient — Fond gradient avec glassmorphism
class GlassGradient extends StatelessWidget {
  final Widget child;
  final Color startColor;
  final Color endColor;
  final Alignment begin;
  final Alignment end;

  const GlassGradient({
    Key? key,
    required this.child,
    this.startColor = const Color(0xFF1E40AF),
    this.endColor = const Color(0xFF059669),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [startColor, endColor],
        ),
      ),
      child: child,
    );
  }
}

/// GlassInput — Champ de saisie avec glassmorphism
class GlassInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double borderRadius;
  final EdgeInsets padding;

  const GlassInput({
    Key? key,
    this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = ThemeColors(isDark: isDark);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: colors.onSurfaceSecondary.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: padding,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: colors.border.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: colors.border.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(
                color: HezaColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: colors.glassSurface.withValues(
              alpha: isDark ? 0.4 : 0.8,
            ),
          ),
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
