import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class VendorDiscountStrip extends StatelessWidget {
  final String discountText;

  const VendorDiscountStrip({
    super.key,
    required this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.vendorBG,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_outlined,
            size: AppDimensions.iconM,
            color: AppColors.vendorText,
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              AppStrings.modalVendorDiscount,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: AppDimensions.fontM,
                fontWeight: FontWeight.bold,
                color: AppColors.vendorText,
              ),
            ),
          ),
          Text(
            discountText,
            style: TextStyle(fontFamily: 'JetBrainsMono', 
              fontSize: AppDimensions.fontM,
              fontWeight: FontWeight.w900,
              color: AppColors.vendorText,
            ),
          ),
        ],
      ),
    );
  }
}
