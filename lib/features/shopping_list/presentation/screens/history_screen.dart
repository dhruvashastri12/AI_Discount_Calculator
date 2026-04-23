import 'package:flutter/material.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:ai_discount_calculator/core/services/data_service.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';
import 'shopping_list_screen.dart';

/// Screen displaying the history of past shopping lists grouped by date.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to data changes to refresh history view
    dataService.addListener(_updateUI);
  }

  @override
  void dispose() {
    dataService.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.background
        : AppColors.backgroundLight;

    final historyData = dataService.historyData;
    // Remove days with zero items if any
    historyData.removeWhere((day) => (day['details'] as List).isEmpty);
    final monthlyTotal = dataService.getMonthlyTotal();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Monthly Summary Card at the top
            _buildMonthlySummaryCard(monthlyTotal),

            // Main history list
            Expanded(
              child: historyData.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(historyData, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top card showing the total spending for the current month.
  Widget _buildMonthlySummaryCard(double monthlyTotal) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceL),
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryList,
            AppColors.primaryList.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXXL - 8),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryList.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            color: AppColors.white,
            size: AppConstants.iconSizeXL + 4,
          ),
          const SizedBox(width: AppConstants.spaceL),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${DateFormat(AppStrings.formatMonthYear).format(DateTime.now()).toUpperCase()} ${AppStrings.historyTotal}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: AppConstants.fontSizeS,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS),
              Text(
                "${AppStrings.calcRupeeSymbol}${monthlyTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: AppConstants.fontSizeGiant / 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds empty state for when no history data is available.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: AppConstants.iconSizeGiant,
            color: AppColors.textMuted.withValues(alpha: 0.2),
          ),
          const SizedBox(height: AppConstants.spaceL),
          const Text(
            AppStrings.historyEmpty,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: AppConstants.fontSizeL,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of history item records.
  Widget _buildHistoryList(
    List<Map<String, dynamic>> historyData,
    bool isDark,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
      physics: const BouncingScrollPhysics(),
      itemCount: historyData.length,
      itemBuilder: (context, index) {
        final day = historyData[index];
        final date = DateTime.parse(day["date"]);
        final List details = day["details"];

        return Card(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
          elevation: isDark ? 0 : 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusXL),
            side: BorderSide(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceXL,
                vertical: AppConstants.spaceS,
              ),
              leading: Container(
                padding: const EdgeInsets.all(AppConstants.spaceS),
                decoration: BoxDecoration(
                  color: AppColors.primaryList.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusM,
                  ),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primaryList,
                  size: AppConstants.iconSizeS + 2,
                ),
              ),
              title: Text(
                DateFormat(AppStrings.formatFullDayDate).format(date),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeL,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              subtitle: Text(
                "${day['items_count']} ${AppStrings.listPurchasedLabel}",
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: AppConstants.fontSizeM + 1,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${AppStrings.calcRupeeSymbol}${day['total'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeXL,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryList,
                    ),
                  ),
                  const Icon(
                    Icons.expand_more,
                    size: AppConstants.iconSizeXL - 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              children: [_buildOrderDetails(details, day['total'], isDark)],
            ),
          ),
        );
      },
    );
  }

  /// Handles individual item editing from history.
  void _editHistoryItem(Map itemData) {
    CartItem? item;
    try {
      // Try to parse as full CartItem if format matches
      item = CartItem.fromJson(Map<String, dynamic>.from(itemData));
    } catch (e) {
      // Fallback for older simpler map format
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemModal(
        editItem: item,
        onItemAdded: (name, qty, unit, unitPrice, discount, discountType, priceMode, catId, date) {
          final updatedItem = CartItem(
            id: item!.id,
            title: name,
            qty: priceMode == PriceMode.flat ? unit : "${qty.toString().replaceAll(RegExp(r'\.0$'), '')} $unit",
            price: _calculateFinalPrice(qty, unitPrice, discount, discountType, priceMode),
            originalPrice: discount > 0 ? (priceMode == PriceMode.flat ? unitPrice : unitPrice * qty) : null,
            discountLabel: _buildDiscountLabel(discount, discountType),
            iconCode: item.iconCode,
            date: date,
            unitPrice: unitPrice,
            rawQty: qty,
            unit: unit,
            discountValue: discount,
            discountType: discountType,
            priceMode: priceMode,
            categoryId: catId,
          );
          dataService.updateItem(updatedItem, alsoInHistory: true);
        },
      ),
    );
  }

  double _calculateFinalPrice(
    double qty,
    double unitPrice,
    double discount,
    DiscountType discountType,
    PriceMode priceMode,
  ) {
    double total = priceMode == PriceMode.flat ? unitPrice : (qty * unitPrice);
    if (discountType == DiscountType.percentage) {
      return total * (1 - discount / 100);
    } else {
      return total - discount;
    }
  }

  String? _buildDiscountLabel(double discount, DiscountType type) {
    if (discount <= 0) return null;
    return type == DiscountType.percentage
        ? "${discount.toStringAsFixed(0)}% OFF"
        : "₹${discount.toStringAsFixed(0)} OFF";
  }

  /// Handles individual item deletion from history.
  void _confirmDeleteHistoryItem(Map itemData) async {
    final String? id = itemData['id'];
    if (id == null) return;

    final bool? delete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.listDeleteConfirmTitle),
        content: const Text(AppStrings.listDeleteConfirmMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.listBtnKeepIt),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.listBtnYesDelete),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (delete == true) {
      dataService.removeItem(id, alsoFromHistory: true);
    }
  }

  /// Builds the expanded section showing individual item details of a past order.
  Widget _buildOrderDetails(List details, dynamic total, bool isDark) {
    return Container(
      color: isDark
          ? AppColors.white.withValues(alpha: 0.02)
          : Colors.grey.withValues(alpha: 0.05),
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      child: Column(
        children: [
          ...details.asMap().entries.map((entry) {
            final int idx = entry.key;
            final item = entry.value;
            final bool isFullItem = item is Map && item.containsKey('id');
            return Column(
              children: [
                if (idx > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppConstants.spaceL),
                    child: Divider(
                      color: isDark 
                          ? AppColors.white.withValues(alpha: 0.1) 
                          : Colors.grey.withValues(alpha: 0.2),
                      height: 1,
                    ),
                  ),
                Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.spaceL),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? item['title'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConstants.fontSizeM + 2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${item['qty']} @ ${AppStrings.calcRupeeSymbol}${((item['unitPrice'] ?? ((item['price'] ?? 0) / (double.tryParse(item['qty'].toString().split(' ')[0]) ?? 1.0))) as num).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: AppConstants.fontSizeM,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (item['discount'] != null ||
                                    item['discountLabel'] != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    margin: const EdgeInsets.only(
                                      bottom: AppConstants.spaceXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadiusS / 2,
                                      ),
                                    ),
                                    child: Text(
                                      item['discount'] ?? item['discountLabel'],
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: AppConstants.fontSizeXS,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                Text(
                                  "${AppStrings.calcRupeeSymbol}${((item['total'] ?? item['price']) as num).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppConstants.fontSizeM + 2,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            if (isFullItem)
                              const SizedBox(width: AppConstants.spaceXXL + 4),
                          ],
                        ),
                      ),
                      if (isFullItem) ...[
                        Positioned(
                          top: -15,
                          right: -15,
                          child: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primaryList,
                              size: AppConstants.iconSizeS + 2,
                            ),
                            onPressed: () => _editHistoryItem(item),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          right: -15,
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.error,
                              size: AppConstants.iconSizeS + 4,
                            ),
                            onPressed: () => _confirmDeleteHistoryItem(item),
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            splashRadius: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          }),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.historyDayTotal,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                "${AppStrings.calcRupeeSymbol}${(total as num).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.fontSizeL,
                  color: AppColors.primaryList,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
