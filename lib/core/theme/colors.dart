import 'package:flutter/material.dart';

/// Centralized color palette for the app.
///
/// Tokens mirror the "Mindful Breathing — neon on photography" direction: a near-black
/// (or, in light mode, a pale mint) ground under real photography, with a
/// neon green primary and cyan secondary drawn in light on top.
class AppColors {
  // ---- Dark theme (default) ----
  static const Color darkBg = Color(0xFF050D09);
  static const Color darkFg = Color(0xFFE9FFF3);
  static const Color darkMuted = Color(0xFF8AA89A);
  static const Color darkNeon = Color(0xFF3DFF9E); // primary accent
  static const Color darkNeon2 = Color(0xFF22E0FF); // secondary accent
  static const Color darkInk = Color(0xFF03170E); // text on neon fill
  static const Color darkGlass = Color(0xFFE9FFF3); // use with low opacity
  static const Color darkLine = Color(0xFF3DFF9E); // use with low opacity
  static const Color darkCardBg = Color(0xFF06120D); // use with opacity ~.62

  // ---- Light theme ----
  static const Color lightBg = Color(0xFFEEF3EE);
  static const Color lightFg = Color(0xFF08150E);
  static const Color lightMuted = Color(0xFF5D7367);
  static const Color lightNeon = Color(0xFF00C46A);
  static const Color lightNeon2 = Color(0xFF0AA9C9);
  static const Color lightInk = Color(0xFFFFFFFF);
  static const Color lightGlass = Color(0xFFFFFFFF); // use with opacity ~.7
  static const Color lightLine = Color(0xFF00C46A); // use with low opacity
  static const Color lightCardBg = Color(0xFFFFFFFF);

  // Background gradients used behind photography
  static const List<Color> darkScrim = [
    Color(0xE6050D09), // ~90%
    Color(0x33050D09), // ~20%
    Color(0xF5050D09), // ~96%
  ];

  // Breathing phase colors (dark ground)
  static const Color inhaleColor = darkNeon;
  static const Color holdColor = darkNeon2;
  static const Color exhaleColor = darkNeon;
}

/// Theme-aware accessor so widgets don't need to branch on brightness
/// everywhere — call `context.neon` (see extension below) or
/// `NeonTokens.of(context)`.
class NeonTokens {
  final Color bg;
  final Color fg;
  final Color muted;
  final Color neon;
  final Color neon2;
  final Color ink;
  final Color glass;
  final Color line;
  final Color cardBg;
  final bool isDark;

  const NeonTokens({
    required this.bg,
    required this.fg,
    required this.muted,
    required this.neon,
    required this.neon2,
    required this.ink,
    required this.glass,
    required this.line,
    required this.cardBg,
    required this.isDark,
  });

  static const dark = NeonTokens(
    bg: AppColors.darkBg,
    fg: AppColors.darkFg,
    muted: AppColors.darkMuted,
    neon: AppColors.darkNeon,
    neon2: AppColors.darkNeon2,
    ink: AppColors.darkInk,
    glass: AppColors.darkGlass,
    line: AppColors.darkLine,
    cardBg: AppColors.darkCardBg,
    isDark: true,
  );

  static const light = NeonTokens(
    bg: AppColors.lightBg,
    fg: AppColors.lightFg,
    muted: AppColors.lightMuted,
    neon: AppColors.lightNeon,
    neon2: AppColors.lightNeon2,
    ink: AppColors.lightInk,
    glass: AppColors.lightGlass,
    line: AppColors.lightLine,
    cardBg: AppColors.lightCardBg,
    isDark: false,
  );

  static NeonTokens of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}
