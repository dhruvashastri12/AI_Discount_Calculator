import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';

/// A placeholder screen for the unit conversion feature.
class ConversionScreen extends StatelessWidget {
  const ConversionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine theme brightness for proper styling
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? AppColors.background : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Prominent placeholder icon with branded circle
            Container(
              padding: const EdgeInsets.all(AppConstants.spaceXXL),
              decoration: BoxDecoration(
                color: AppColors.primaryList.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.swap_horiz,
                size: AppConstants.iconSizeXL * 2,
                color: AppColors.primaryList,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXXL),
            
            // Major notice text
            Text(
              AppStrings.convComingSoon,
              style: GoogleFonts.spaceGrotesk(
                fontSize: AppConstants.fontSizeXXL + 2,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppConstants.spaceS),
            
            // Encouraging flavor text
            const Text(
              AppStrings.convFlavorText,
              style: TextStyle(color: AppColors.textMuted, fontSize: AppConstants.fontSizeM),
            ),
          ],
        ),
      ),
    );
  }
}

