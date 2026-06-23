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
import '../../../../shared/widgets/modal_rate_input.dart';
import '../../../../shared/widgets/discount_type_toggle.dart';
import '../../../../shared/widgets/category_header.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<String> _expandedMonths = {};
  final Set<String> _expandedDays = {};
  String? _expandedItemId;

  final Set<String> _visibleRoundOffCategories = {};
  final Set<String> _categoriesInEditMode = {};
  final Map<String, TextEditingController> _roundOffControllers = {};
  final Map<String, DiscountType> _roundOffTypes = {};

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
    for (var controller in _roundOffControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  bool _isRoundOffVisible(String categoryId) {
    final savedVal = dataService.getCategoryRoundOffValue(categoryId);
    if (savedVal > 0 && !_visibleRoundOffCategories.contains(categoryId)) {
      _roundOffControllers.putIfAbsent(
        categoryId,
        () => TextEditingController(
          text: savedVal.toString().replaceAll(RegExp(r'\.0$'), ''),
        ),
      );
      _roundOffTypes.putIfAbsent(
        categoryId,
        () => dataService.getCategoryRoundOffType(categoryId),
      );
      _visibleRoundOffCategories.add(categoryId);
    }
    return _visibleRoundOffCategories.contains(categoryId);
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

  double _computeDayTotal(List<CartItem> items) {
    final groups = dataService.groupItemsByCategory(items);
    double total = 0;
    for (var entry in groups.entries) {
      total += dataService.getCategoryTotal(entry.key, entry.value);
    }
    return total;
  }

  double _computeDaySavings(List<CartItem> items) {
    double rawSubtotal = items.fold(0.0, (sum, it) => sum + it.subtotal);
    double dayTotal = _computeDayTotal(items);
    return (rawSubtotal - dayTotal).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final rawHistory = dataService.historyByDate;

    // Filter to show only sessions dated strictly before today
    final Map<DateTime, List<CartItem>> history = {};
    rawHistory.forEach((date, items) {
      if (date.isBefore(todayDate)) {
        history[date] = items;
      }
    });

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
            _buildAllTimeSummaryCard(isDark, history),
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

  Widget _buildAllTimeSummaryCard(bool isDark, Map<DateTime, List<CartItem>> history) {
    // Compute totals from filtered history (excludes today)
    double historyExpense = 0;
    double historySavings = 0;
    history.forEach((date, items) {
      historyExpense += _computeDayTotal(items);
      historySavings += _computeDaySavings(items);
    });

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
                    '₹${historyExpense.toStringAsFixed(0)}',
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
                    '₹${historySavings.toStringAsFixed(0)}',
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
      monthTotal += _computeDayTotal(items);
      monthSavings += _computeDaySavings(items);
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
    double dayTotal = _computeDayTotal(items);
    double daySavings = _computeDaySavings(items);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = items
        .map((it) => it.categoryId)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .toList();
    String categoriesText = "";
    if (categories.isNotEmpty) {
      final displayCats = categories.take(3).map((c) {
        if (c.isEmpty) return "";
        return c[0].toUpperCase() + c.substring(1).toLowerCase();
      }).toList();
      categoriesText = displayCats.join(" + ");
      if (categories.length > 3) {
        categoriesText += " + more";
      }
    }

    final groups = dataService.groupItemsByCategory(items);

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
                        if (categoriesText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            categoriesText,
                            style: TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: AppDimensions.fontXS,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutralText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (daySavings.round() > 0)
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
                            'Saved ₹ ${daySavings.toStringAsFixed(0)}',
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
            const Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppColors.borderDefault,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              child: Column(
                children: groups.entries.expand((entry) {
                  final categoryId = entry.key;
                  final catItems = entry.value;
                  return [
                    CategoryHeader(
                      emoji: _getEmojiForCategory(categoryId),
                      title: categoryId,
                      itemCount: catItems.length,
                      subtotal: dataService.getCategoryTotal(categoryId, catItems),
                      showRoundOffIcon: catItems.length > 1,
                      onRoundOffTap: () {
                        setState(() {
                          if (_visibleRoundOffCategories.contains(categoryId)) {
                            _visibleRoundOffCategories.remove(categoryId);
                          } else {
                            _visibleRoundOffCategories.add(categoryId);
                            final savedVal = dataService.getCategoryRoundOffValue(categoryId);
                            if (savedVal > 0) {
                              _categoriesInEditMode.remove(categoryId);
                            } else {
                              _categoriesInEditMode.add(categoryId);
                            }
                            final controller = _roundOffControllers.putIfAbsent(
                              categoryId,
                              () => TextEditingController(
                                text: savedVal > 0 ? savedVal.toString().replaceAll(RegExp(r'\.0$'), '') : ''
                              )
                            );
                            controller.text = savedVal > 0 ? savedVal.toString().replaceAll(RegExp(r'\.0$'), '') : '';
                            _roundOffTypes.putIfAbsent(
                              categoryId,
                              () => dataService.getCategoryRoundOffType(categoryId)
                            );
                          }
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    if (_isRoundOffVisible(categoryId)) ...[
                      _buildRoundOffDiscountSection(categoryId, catItems),
                      const SizedBox(height: AppDimensions.paddingS),
                    ],
                    ...catItems.map(
                      (it) => ItemCard(
                        item: it,
                        isExpanded: _expandedItemId == it.id,
                        onToggle: () => setState(
                          () =>
                              _expandedItemId = _expandedItemId == it.id ? null : it.id,
                        ),
                        onEdit: () => _showEditModal(it),
                        onDelete: () => _showDeleteConfirmation(it),
                        showDate: false,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                  ];
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoundOffDiscountSection(String categoryId, List<CartItem> items) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool inEditMode = _categoriesInEditMode.contains(categoryId);
    final type = _roundOffTypes[categoryId] ?? DiscountType.flat;
    final controller = _roundOffControllers[categoryId] ?? TextEditingController();

    if (inEditMode) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AppColors.vendorOffBG,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.vendorOffBorder,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            const Text(
              'Round off discount',
              style: TextStyle(
                fontFamily: 'DMSans',
                color: AppColors.vendorOffLabel,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ModalRateInput(
                controller: controller,
                hint: '0',
                fontSize: 13,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 8),
            DiscountTypeToggle(
              selected: type,
              onSelected: (val) {
                setState(() {
                  _roundOffTypes[categoryId] = val;
                });
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  dataService.setCategoryRoundOff(categoryId, 0, type);
                  setState(() {
                    _categoriesInEditMode.remove(categoryId);
                    _visibleRoundOffCategories.remove(categoryId);
                  });
                  return;
                }
                final val = double.tryParse(text);
                if (val == null || val <= 0 || val > 10) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Round off discount must be above 0 and maximum 10.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                dataService.setCategoryRoundOff(categoryId, val, type);
                setState(() {
                  _categoriesInEditMode.remove(categoryId);
                });
              },
            ),
          ],
        ),
      );
    } else {
      final savedVal = dataService.getCategoryRoundOffValue(categoryId);
      final displayVal = savedVal.toString().replaceAll(RegExp(r'\.0$'), '');
      return GestureDetector(
        onTap: () {
          setState(() {
            _categoriesInEditMode.add(categoryId);
          });
        },
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : AppColors.vendorOffBG,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: AppColors.vendorOffBorder,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Round off discount',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: AppColors.vendorOffLabel,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    type == DiscountType.percentage ? '$displayVal%' : '₹$displayVal',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      color: AppColors.vendorOffLabel,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: AppColors.vendorOffLabel.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
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
