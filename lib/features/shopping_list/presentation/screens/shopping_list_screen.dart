import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/models/cart_item.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_modal.dart';
import '../../../../shared/widgets/summary_card.dart';
import '../../../../shared/widgets/savings_strip.dart';
import '../../../../shared/widgets/category_header.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  String? _expandedItemId;

  @override
  void initState() {
    super.initState();
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

  void _showAddModal({CartItem? editItem}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: AddItemModal(
          editItem: editItem,
          onItemAdded: (item) {
            if (editItem != null) {
              dataService.updateItem(item);
            } else {
              dataService.addItem(item);
            }
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(CartItem item) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime itemDate = DateTime(
      item.date.year,
      item.date.month,
      item.date.day,
    );
    bool isPastDate = itemDate.isBefore(today);

    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.dialogConfirmDelete),
        content: const Text('\${AppStrings.dialogDeleteMsg}\n\n\${AppStrings.dialogDeleteWarning}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.listBtnKeepIt),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.listBtnYesDelete,
              style: TextStyle(fontFamily: 'DMSans', color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (deleteConfirmed != true) return;

    if (!mounted) return;

    if (isPastDate) {
      bool? deleteFromHistory = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.dialogDeleteHistoryTitle),
          content: const Text('${AppStrings.dialogDeleteHistoryMsg}\n\n${AppStrings.dialogDeleteWarning}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.listBtnKeepIt),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                AppStrings.listBtnYesDelete,
                style: TextStyle(fontFamily: 'DMSans', color: AppColors.error),
              ),
            ),
          ],
        ),
      );

      if (deleteFromHistory == true) {
        if (mounted) dataService.removeItem(item.id);
      }
    } else {
      if (mounted) dataService.removeItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryCard(),
            Expanded(
              child: dataService.currentItems.isEmpty
                  ? _buildEmptyState()
                  : _buildGroupedList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddModal(),
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXL)),
        child: const Icon(Icons.add, color: AppColors.white, size: AppDimensions.iconFAB),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final double subtotal = dataService.subtotal;
    final double savings = dataService.totalSavings;
    final double finalTotal = dataService.finalTotalValue;
    final int savingsPercent = subtotal > 0
        ? ((savings / subtotal) * 100).round()
        : 0;

    return SummaryCard(
      margin: const EdgeInsets.fromLTRB(AppDimensions.paddingL, AppDimensions.paddingM, AppDimensions.paddingL, 0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.listSubtotalSavings,
                    style: TextStyle(fontFamily: 'DMSans', 
                      fontSize: AppDimensions.fontS - 1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutralText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${subtotal.toStringAsFixed(0)}',
                        style: TextStyle(fontFamily: 'JetBrainsMono', 
                          fontSize: AppDimensions.fontTitleL,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingXS),
                      if (savings > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '-₹${savings.toStringAsFixed(0)}',
                            style: TextStyle(fontFamily: 'JetBrainsMono', 
                              fontSize: AppDimensions.fontL,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 30, color: AppColors.dividerGrey),
            const SizedBox(width: AppDimensions.paddingL),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.listFinalTotal,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: AppDimensions.fontS - 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutralText,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${finalTotal.toStringAsFixed(0)}',
                  style: TextStyle(fontFamily: 'JetBrainsMono', 
                    fontSize: AppDimensions.fontDisplayM,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        SavingsStrip(amount: savings, percentage: savingsPercent),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            AppStrings.listEmptyMsg,
            style: TextStyle(fontFamily: 'DMSans', fontSize: AppDimensions.fontTitleS, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList() {
    final currentDayItems = dataService.currentItems;
    final groups = dataService.groupItemsByCategory(currentDayItems);
    if (currentDayItems.isEmpty) return _buildEmptyState();

    DateTime firstDate = currentDayItems.first.date;
    String dateStr = DateFormat(AppStrings.formatShortDate).format(firstDate).toUpperCase();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: AppDimensions.paddingS + 2),
      itemCount: groups.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingS + 2, bottom: AppDimensions.paddingL),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Text(
                  dateStr,
                  style: TextStyle(fontFamily: 'DMSans', 
                    fontSize: AppDimensions.fontS,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }

        final categoryId = groups.keys.elementAt(index - 1);
        final items = groups[categoryId]!;
        final catSubtotal = items.fold(
          0.0,
          (sum, it) => sum + it.itemAfterVendorDiscount,
        );

        return Column(
          children: [
            CategoryHeader(
              emoji: _getEmojiForCategory(categoryId),
              title: categoryId,
              itemCount: items.length,
              subtotal: catSubtotal,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            ...items.map(
              (item) => ItemCard(
                item: item,
                isExpanded: _expandedItemId == item.id,
                onToggle: () => setState(
                  () => _expandedItemId = _expandedItemId == item.id
                      ? null
                      : item.id,
                ),
                onEdit: () => _showAddModal(editItem: item),
                onDelete: () => _showDeleteConfirmation(item),
                showDate: false,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
          ],
        );
      },
    );
  }

  String _getEmojiForCategory(String name) {
    String n = name.toUpperCase();
    if (n.contains('VEG')) return '🥦';
    if (n.contains('DAIRY')) return '🥛';
    if (n.contains('GROCERY')) return '🛒';
    if (n.contains('HOUSEHOLD') || n.contains('HOME')) return '🏠';
    if (n.contains('CLOTH')) return '👗';
    if (n.contains('STATIO')) return '✏️';
    if (n.contains('ELECTRO')) return '📱';
    if (n.contains('HEALTH')) return '💊';
    if (n.contains('BEAUTY')) return '💄';
    return '🏷️';
  }
}
