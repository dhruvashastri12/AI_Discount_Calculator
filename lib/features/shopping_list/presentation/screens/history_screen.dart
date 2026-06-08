import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/services/data_service.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_modal.dart';
import '../../../../shared/widgets/dashed_border_container.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _expandedMonths = {};
  final Set<String> _expandedDays = {};
  String? _expandedItemId;

  @override
  void initState() {
    super.initState();
    dataService.addListener(_updateUI);
    final now = DateTime.now();
    _expandedMonths.add("${now.year}-${now.month}");
  }

  @override
  void dispose() {
    dataService.removeListener(_updateUI);
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  void _showEditModal(CartItem item) {
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
          editItem: item,
          onItemAdded: (updated) {
            dataService.updateItem(updated);
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(CartItem item) async {
    bool? deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.dialogConfirmDelete,
          style: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${AppStrings.dialogDeleteMsg}\n\n${AppStrings.dialogDeleteWarning}',
          style: TextStyle(fontFamily: 'DMSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppStrings.listBtnKeepIt,
              style: TextStyle(fontFamily: 'DMSans', color: Colors.grey),
            ),
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

    if (deleteConfirmed == true) {
      dataService.removeItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = dataService.historyByDate;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, Map<DateTime, List<CartItem>>> monthlyHistory = {};
    history.forEach((date, items) {
      String monthKey = "${date.year}-${date.month}";
      monthlyHistory.putIfAbsent(monthKey, () => {});
      monthlyHistory[monthKey]![date] = items;
    });

    final sortedMonthKeys = monthlyHistory.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('-').map(int.parse).toList();
        final bParts = b.split('-').map(int.parse).toList();
        if (aParts[0] != bParts[0]) return bParts[0].compareTo(aParts[0]);
        return bParts[1].compareTo(aParts[1]);
      });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildAllTimeSummaryCard(isDark),
            Expanded(
              child: monthlyHistory.isEmpty
                  ? _buildEmptyHistory()
                  : _buildMonthlyList(monthlyHistory, sortedMonthKeys),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeSummaryCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingL,
        AppDimensions.paddingL,
        AppDimensions.paddingS,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.darkGreen],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL + 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.historyAllTimeSummary,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: AppDimensions.fontXS,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.historyExpense,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: AppDimensions.fontS,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '₹${dataService.allTimeExpense.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: AppDimensions.fontTitleXL,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppStrings.historySavings,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: AppDimensions.fontS,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                  ),
                  Text(
                    '₹${dataService.allTimeSavings.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: AppDimensions.fontTitleXL,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(
    String monthKey,
    Map<DateTime, List<CartItem>> days,
  ) {
    double monthTotal = 0;
    double monthSavings = 0;

    days.forEach((date, items) {
      for (var item in items) {
        monthTotal += item.itemAfterVendorDiscount;
        monthSavings += item.totalSavings;
      }
    });

    final parts = monthKey.split('-');
    final monthDate = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final now = DateTime.now();
    bool isCurrentMonth =
        now.year == monthDate.year && now.month == monthDate.month;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isExpanded = _expandedMonths.contains(monthKey);

    return GestureDetector(
      onTap: () => setState(
        () => isExpanded
            ? _expandedMonths.remove(monthKey)
            : _expandedMonths.add(monthKey),
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: DashedBorderContainer(
          color: AppColors.monthlyCardBorder,
          strokeWidth: 1,
          dashPattern: const [4, 4],
          borderRadius: AppDimensions.radiusXXL,
          backgroundColor: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.monthlyCardBG,
          padding: const EdgeInsets.all(AppDimensions.paddingXL - 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentMonth
                        ? AppStrings.historyThisMonth
                        : AppStrings.historyPastMonth,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: AppDimensions.fontXS,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutralText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Row(
                    children: [
                      Text(
                        DateFormat(
                          AppStrings.formatMonthYear,
                        ).format(monthDate),
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: AppDimensions.fontTitleM,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingXS),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: AppDimensions.iconM,
                        color: AppColors.neutralText,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.historySpent,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: AppDimensions.fontM,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutralText,
                        ),
                      ),
                      Text(
                        '₹${monthTotal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: AppDimensions.fontDisplayS,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS - 2),
                  if (monthSavings > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS + 2,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      child: Text(
                        '${AppStrings.historySaved} ₹${monthSavings.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: AppDimensions.fontS,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 60,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            AppStrings.historyEmptyMsg,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: AppDimensions.fontS + 1,
              color: AppColors.neutralText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyList(
    Map<String, Map<DateTime, List<CartItem>>> monthlyHistory,
    List<String> sortedMonthKeys,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingS,
      ),
      itemCount: sortedMonthKeys.length,
      itemBuilder: (context, index) {
        final monthKey = sortedMonthKeys[index];
        final days = monthlyHistory[monthKey]!;
        final sortedDates = days.keys.toList()..sort((a, b) => b.compareTo(a));
        bool isExpanded = _expandedMonths.contains(monthKey);

        return Column(
          children: [
            _buildMonthlySummaryCard(monthKey, days),
            if (isExpanded) ...[
              const SizedBox(height: AppDimensions.paddingS),
              ...sortedDates.map((date) => _buildDayCard(date, days[date]!)),
            ],
            const SizedBox(height: AppDimensions.paddingL),
          ],
        );
      },
    );
  }

  Widget _buildDayCard(DateTime date, List<CartItem> items) {
    String dayKey = DateFormat('yyyy-MM-dd').format(date);
    bool isExpanded = _expandedDays.contains(dayKey);
    double dayTotal = items.fold(
      0.0,
      (sum, it) => sum + it.itemAfterVendorDiscount,
    );
    double daySavings = items.fold(0.0, (sum, it) => sum + it.totalSavings);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL + 4),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(
              () => isExpanded
                  ? _expandedDays.remove(dayKey)
                  : _expandedDays.add(dayKey),
            ),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingXL),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            AppStrings.formatFullDayDate,
                          ).format(date).toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: AppDimensions.fontS - 1,
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutralText,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Text(
                          '₹${dayTotal.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: AppDimensions.fontTitleL,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.white
                                : AppColors.navBarDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (daySavings > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenTint,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusM,
                            ),
                          ),
                          child: Text(
                            'Saved ₹${daySavings.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: AppDimensions.fontXS,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppDimensions.paddingL),
                      Icon(
                        isExpanded
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: AppColors.neutralText.withValues(alpha: 0.5),
                        size: 28,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, indent: 20, endIndent: 20),
            ...items.map(
              (it) => ItemCard(
                item: it,
                isExpanded: _expandedItemId == it.id,
                onToggle: () => setState(
                  () =>
                      _expandedItemId = _expandedItemId == it.id ? null : it.id,
                ),
                onEdit: () => _showEditModal(it),
                onDelete: () => _showDeleteConfirmation(it),
                showDate: true,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
