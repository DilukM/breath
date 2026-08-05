import 'package:flutter/material.dart';
import 'colors.dart';

/// Defines light and dark themes for the app
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'SpaceGrotesk',
      primaryColor: AppColors.lightNeon,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.light(
        primary: AppColors.lightNeon,
        secondary: AppColors.lightNeon2,
        surface: AppColors.lightBg,
        onPrimary: AppColors.lightInk,
        onSecondary: AppColors.lightInk,
        onSurface: AppColors.lightFg,
      ),
      textTheme: _textTheme(AppColors.lightFg, AppColors.lightMuted),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightNeon,
          foregroundColor: AppColors.lightInk,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'SpaceGrotesk',
      primaryColor: AppColors.darkNeon,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkNeon,
        secondary: AppColors.darkNeon2,
        surface: AppColors.darkBg,
        onPrimary: AppColors.darkInk,
        onSecondary: AppColors.darkInk,
        onSurface: AppColors.darkFg,
      ),
      textTheme: _textTheme(AppColors.darkFg, AppColors.darkMuted),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkNeon,
          foregroundColor: AppColors.darkInk,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color fg, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 38,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.4,
        color: fg,
      ),
      displayMedium: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 30,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.3,
        color: fg,
      ),
      displaySmall: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: fg,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: fg,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: fg,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: muted,
      ),
      bodySmall: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: muted,
      ),
    );
  }
}
