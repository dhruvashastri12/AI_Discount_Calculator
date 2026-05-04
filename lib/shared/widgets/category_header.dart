import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class CategoryHeader extends StatelessWidget {
  final String emoji;
  final String title;
  final int itemCount;
  final double subtotal;

  const CategoryHeader({
    super.key,
    required this.emoji,
    required this.title,
    required this.itemCount,
    required this.subtotal,
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
          child: Text(emoji, style: const TextStyle(fontSize: AppDimensions.fontTitleS)),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: AppDimensions.fontL,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: AppDimensions.fontS,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '₹${subtotal.toStringAsFixed(0)}',
          style: TextStyle(fontFamily: 'JetBrainsMono', 
            fontSize: AppDimensions.fontXXL,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
