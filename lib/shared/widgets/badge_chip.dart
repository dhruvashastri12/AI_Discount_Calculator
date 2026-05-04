import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';


class BadgeChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const BadgeChip({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.greenTint,
    this.textColor = AppColors.darkGreen,
    this.fontSize = AppDimensions.fontXS,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS - 2,
        vertical: AppDimensions.paddingXS - 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Text(
        label,
        style: TextStyle(fontFamily: 'DMSans', 
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }
}
