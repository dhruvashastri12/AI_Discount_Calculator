import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/cart_item.dart';

class MarketSelector extends StatelessWidget {
  final String marketType;
  final Function(String) onMarketChanged;

  const MarketSelector({
    super.key,
    required this.marketType,
    required this.onMarketChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isMall = marketType == 'Mall';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMarketOption(context, AppStrings.modalLocalMarket, '🏘️', !isMall)),
          Expanded(child: _buildMarketOption(context, AppStrings.modalSuperMall, '🏢', isMall)),
        ],
      ),
    );
  }

  Widget _buildMarketOption(BuildContext context, String label, String icon, bool active) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onMarketChanged(label.contains('Local') ? 'Local' : 'Mall'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
        decoration: BoxDecoration(
          color: active ? (isDark ? AppColors.darkGreen : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: active && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon),
            const SizedBox(width: AppDimensions.paddingXS),
            Text(
              label,
              style: TextStyle(fontFamily: 'DMSans', 
                fontSize: AppDimensions.fontS,
                fontWeight: FontWeight.bold,
                color: active ? (isDark ? Colors.white : AppColors.textDark) : AppColors.neutralText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceModeToggle extends StatelessWidget {
  final PriceMode priceMode;
  final Function(PriceMode) onModeChanged;

  const PriceModeToggle({
    super.key,
    required this.priceMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton(context, PriceMode.flatRate, '💰', AppStrings.modalFlatRate, AppStrings.modalTotalAmount)),
          Expanded(child: _buildToggleButton(context, PriceMode.perUnit, '📐', AppStrings.modalPerUnit, AppStrings.modalRatePerUnit)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, PriceMode mode, String icon, String title, String hint) {
    bool isSelected = priceMode == mode;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.darkGreen : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: isSelected && !isDark ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 4)] : null,
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.5,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(icon),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.bold, fontSize: AppDimensions.fontS),
                  ),
                ],
              ),
              Text(
                hint,
                style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontXS, color: AppColors.neutralText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
