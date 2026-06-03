import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../shared/widgets/badge_chip.dart';
import '../../../../shared/widgets/price_display.dart';
import '../../../../shared/widgets/vendor_discount_strip.dart';

class ItemCard extends StatelessWidget {
  final CartItem item;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDate;

  const ItemCard({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool hasDiscount = item.totalSavings > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 8, 
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onToggle,
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.itemName, 
                                style: TextStyle(fontFamily: 'DMSans', 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: AppDimensions.fontXXL, 
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: AppDimensions.paddingS),
                              BadgeChip(
                                label: '${AppStrings.listSavedBadge}${item.totalSavings.toStringAsFixed(0)}',
                              ),
                            ],
                          ],
                        ),
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              DateFormat(AppStrings.formatShortDate).format(item.date).toUpperCase(), 
                              style: TextStyle(fontFamily: 'DMSans', 
                                fontSize: AppDimensions.fontXS, 
                                fontWeight: FontWeight.w900, 
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.quantity, 
                                style: TextStyle(fontFamily: 'DMSans', 
                                  fontSize: AppDimensions.fontM, 
                                  fontWeight: FontWeight.w600, 
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingS),
                            PriceDisplay(
                              originalPrice: item.itemFinalPrice,
                              finalPrice: item.itemAfterVendorDiscount,
                              hasDiscount: hasDiscount,
                              fontSize: AppDimensions.fontL,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
          if (isExpanded) _buildDetailPanel(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        GestureDetector(
          onTap: onEdit, 
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.blueTint, 
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.edit_outlined, size: AppDimensions.iconS, color: AppColors.blueText),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingS),
        GestureDetector(
          onTap: onDelete, 
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.errorTint, 
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: const Icon(Icons.delete_outline, size: AppDimensions.iconS, color: AppColors.errorText),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPanel(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String? formula;
    if (item.priceMode == PriceMode.perUnit) {
      formula = "${item.boughtQty}${item.boughtUnit} ÷ ${item.baseQty}${item.baseUnit} × ₹${item.enteredAmount}";
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingM, 0, AppDimensions.paddingM, AppDimensions.paddingM),
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.dividerGrey),
          const SizedBox(height: AppDimensions.paddingS + 2),
          if (item.vendorDiscountValue > 0)
            VendorDiscountStrip(
              discountText: item.vendorDiscountType == DiscountType.percentage 
                  ? '${item.vendorDiscountValue.toStringAsFixed(0)}%' 
                  : '₹${item.vendorDiscountValue.toStringAsFixed(0)}',
            ),
          const SizedBox(height: AppDimensions.paddingS + 2),
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingS + 2),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(AppDimensions.radiusM + 2),
            ),
            child: Column(
              children: [
                _buildDetailRow(context, AppStrings.labelMode, item.priceMode == PriceMode.flatRate ? '💰 Flat Rate' : '📐 Per Unit'),
                _buildDetailRow(context, AppStrings.labelMarket, item.marketType == 'Local' ? '🏘️ Local Market' : '🏢 Super Mall'),
                if (formula != null) _buildDetailRow(context, AppStrings.labelCalculation, formula),
                if (item.discountValue > 0)
                  _buildDetailRow(context, AppStrings.labelItemOff, item.discountType == DiscountType.percentage ? '${item.discountValue.toStringAsFixed(0)}%' : '₹${item.discountValue.toStringAsFixed(0)}'),
                if (item.vendorDiscountValue > 0)
                  _buildDetailRow(context, AppStrings.labelVendorOff, item.vendorDiscountType == DiscountType.percentage ? '${item.vendorDiscountValue.toStringAsFixed(0)}%' : '₹${item.vendorDiscountValue.toStringAsFixed(0)}'),
                const Divider(height: AppDimensions.paddingL, color: AppColors.dividerGrey),
                _buildDetailRow(context, AppStrings.labelOriginalPrice, '₹${item.itemFinalPrice.toStringAsFixed(2)}'),
                _buildDetailRow(context, AppStrings.labelPaidAmount, '₹${item.itemAfterVendorDiscount.toStringAsFixed(2)}', isBold: true, color: AppColors.primaryGreen),
                _buildDetailRow(context, AppStrings.labelTotalSavings, '₹${item.totalSavings.toStringAsFixed(2)}', isBold: true, color: isDark ? Colors.orange[300] : Colors.orange[800]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isBold = false, Color? color}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontS, fontWeight: FontWeight.bold, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          Text(value, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: AppDimensions.fontS, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: color ?? (isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black.withValues(alpha: 0.87)))),
        ],
      ),
    );
  }
}
