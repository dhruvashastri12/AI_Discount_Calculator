import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class PriceDisplay extends StatelessWidget {
  final double originalPrice;
  final double finalPrice;
  final bool hasDiscount;
  final double fontSize;
  final Color? finalPriceColor;

  const PriceDisplay({
    super.key,
    required this.originalPrice,
    required this.finalPrice,
    required this.hasDiscount,
    this.fontSize = AppDimensions.fontXXL,
    this.finalPriceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount) ...[
          Text(
            '₹${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: fontSize - 1,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingXS),
        ],
        Text(
          '₹${finalPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color:
                finalPriceColor ??
                (hasDiscount
                    ? AppColors.primaryGreen
                    : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.neutralText)),
          ),
        ),
      ],
    );
  }
}
