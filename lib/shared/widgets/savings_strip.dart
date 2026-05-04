import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class SavingsStrip extends StatelessWidget {
  final double amount;
  final int percentage;
  final String? label;

  const SavingsStrip({
    super.key,
    required this.amount,
    required this.percentage,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingS + 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: AppDimensions.iconS),
          const SizedBox(width: AppDimensions.paddingS - 2),
          Text(
            '${label ?? AppStrings.listSavedToday} ${amount.toStringAsFixed(0)}',
            style: TextStyle(fontFamily: 'DMSans', 
              fontSize: AppDimensions.fontL,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
              vertical: AppDimensions.paddingXS - 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(fontFamily: 'JetBrainsMono', 
                color: AppColors.white,
                fontSize: AppDimensions.fontS - 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
