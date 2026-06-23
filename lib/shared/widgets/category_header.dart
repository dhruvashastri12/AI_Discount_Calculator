import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CategoryHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final int itemCount;
  final double subtotal;
  final VoidCallback? onRoundOffTap;
  final bool showRoundOffIcon;

  const CategoryHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.itemCount,
    required this.subtotal,
    this.onRoundOffTap,
    this.showRoundOffIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingS),
          decoration: BoxDecoration(
            color: AppColors.categoryIconBG,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM + 2),
          ),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: AppDimensions.fontTitleS),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: AppDimensions.fontXXL,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: AppDimensions.fontS,
                color: AppColors.neutralText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (showRoundOffIcon) ...[
          GestureDetector(
            onTap: onRoundOffTap,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.greenTint,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: const Icon(
                Icons.discount_outlined,
                size: AppDimensions.iconS,
                color: AppColors.greenText,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '₹${subtotal.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: AppDimensions.fontXXL,
            fontWeight: FontWeight.w900,
            color: AppColors.navBarDark,
          ),
        ),
      ],
    );
  }
}
