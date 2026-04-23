import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized theme configuration for the application.
/// Manages both light and dark mode styles to ensure visual consistency.
class AppTheme {
  /// Defines the visual properties for the application's dark theme.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGreen,
        surface: AppColors.cardDark,
        onSurface: AppColors.white,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    );
  }

  /// Defines the visual properties for the application's light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryGreen,
        surface: AppColors.white,
        onSurface: AppColors.textDark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
    );
  }
}

