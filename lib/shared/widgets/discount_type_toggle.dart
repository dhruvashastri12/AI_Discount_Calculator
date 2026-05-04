import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/models/cart_item.dart';

class DiscountTypeToggle extends StatelessWidget {
  final DiscountType selected;
  final Function(DiscountType) onSelected;

  const DiscountTypeToggle({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          _buildSmallToggleButton('%', selected == DiscountType.percentage, () => onSelected(DiscountType.percentage)),
          _buildSmallToggleButton('₹', selected == DiscountType.flat, () => onSelected(DiscountType.flat)),
        ],
      ),
    );
  }

  Widget _buildSmallToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutralText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
