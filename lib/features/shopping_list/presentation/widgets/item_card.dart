import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/cart_item.dart';

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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
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
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.greenTint, borderRadius: BorderRadius.circular(4)),
                                child: Text('Saved ₹${item.totalSavings.toStringAsFixed(0)}', 
                                  style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
                              ),
                            ],
                          ],
                        ),
                        if (showDate)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(DateFormat('dd MMM yyyy').format(item.date).toUpperCase(), 
                              style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey[400])),
                          ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.quantity, 
                                style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (hasDiscount) ...[
                              Text('₹${item.itemFinalPrice.toStringAsFixed(0)}', 
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                              const SizedBox(width: 4),
                            ],
                            Text('₹${item.itemAfterVendorDiscount.toStringAsFixed(0)}', 
                              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w900, color: hasDiscount ? AppColors.primaryGreen : AppColors.textDark)),
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
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.edit_outlined, size: 14, color: Colors.blue[800]),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete, 
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.delete_outline, size: 14, color: Colors.red[800]),
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          if (item.vendorDiscountValue > 0)
            _buildVendorDiscountBox(),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildDetailRow('Mode', item.priceMode == PriceMode.flatRate ? '💰 Flat Rate' : '📐 Per Unit'),
                _buildDetailRow('Market', item.marketType == 'Local' ? '🏘️ Local Market' : '🏢 Super Mall'),
                if (formula != null) _buildDetailRow('Calculation', formula),
                if (item.discountValue > 0)
                  _buildDetailRow('Item Off', item.discountType == DiscountType.percentage ? '${item.discountValue.toStringAsFixed(0)}%' : '₹${item.discountValue.toStringAsFixed(0)}'),
                if (item.vendorDiscountValue > 0)
                  _buildDetailRow('Vendor Off', item.vendorDiscountType == DiscountType.percentage ? '${item.vendorDiscountValue.toStringAsFixed(0)}%' : '₹${item.vendorDiscountValue.toStringAsFixed(0)}'),
                const Divider(height: 16, color: Color(0xFFEEEEEE)),
                _buildDetailRow('Original Price', '₹${item.itemFinalPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Paid Amount', '₹${item.itemAfterVendorDiscount.toStringAsFixed(2)}', isBold: true, color: AppColors.primaryGreen),
                _buildDetailRow('Total Savings', '₹${item.totalSavings.toStringAsFixed(2)}', isBold: true, color: Colors.orange[800]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorDiscountBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.handshake_outlined, size: 16, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Text('Vendor / Merchant Discount', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF92400E))),
          const Spacer(),
          Text(item.vendorDiscountType == DiscountType.percentage ? '${item.vendorDiscountValue.toStringAsFixed(0)}%' : '₹${item.vendorDiscountValue.toStringAsFixed(0)}', 
            style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.orange[800])),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
