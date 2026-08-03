import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// A frosted, softly-lit panel — the "glass over photograph" card used
/// throughout the neon direction (rhythm card, bottom nav, chips).
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final Color? glowColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.blur = 18,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = NeonTokens.of(context);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tokens.cardBg.withOpacity(tokens.isDark ? 0.62 : 0.7),
            borderRadius: borderRadius,
            border: Border.all(color: tokens.line.withOpacity(0.2)),
            boxShadow: glowColor != null
                ? [
                    BoxShadow(
                      color: glowColor!.withOpacity(0.14),
                      blurRadius: 44,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
