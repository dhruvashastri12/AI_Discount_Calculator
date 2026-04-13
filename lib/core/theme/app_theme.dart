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
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryCalc,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCalc,
        secondary: AppColors.primaryCalc,
        surface: AppColors.surface,
        onSurface: AppColors.white,
      ),
      useMaterial3: true,
      
      // Using Space Grotesk for a modern, tech-focused look in dark mode
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
    );
  }

  /// Defines the visual properties for the application's light theme.
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryList,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryList,
        secondary: AppColors.primaryList,
        surface: AppColors.white,
        onSurface: AppColors.textDark,
      ),
      useMaterial3: true,
      
      // Using Public Sans for high readability in light mode
      textTheme: GoogleFonts.publicSansTextTheme(ThemeData.light().textTheme),
      fontFamily: GoogleFonts.publicSans().fontFamily,
    );
  }
}

