import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/services/data_service.dart';
import '../widgets/item_card.dart';
import '../widgets/add_item_modal.dart';

import 'package:dotted_border/dotted_border.dart';

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
    // Expand current month by default
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
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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
        title: Text('Confirm Delete', style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this item?\n\nDeleted entries cant be retrived back.', style: GoogleFonts.dmSans()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('No, Keep it', style: GoogleFonts.dmSans(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Yes, Delete', style: GoogleFonts.dmSans(color: Colors.red))),
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

    // Group history by Month
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
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAllTimeSummaryCard(),
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

  Widget _buildAllTimeSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.darkGreen]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALL TIME SUMMARY', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EXPENSE', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60)),
                  Text('₹${dataService.allTimeExpense.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SAVINGS', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white60)),
                  Text('₹${dataService.allTimeSavings.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryCard(String monthKey, Map<DateTime, List<CartItem>> days) {
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
    bool isCurrentMonth = now.year == monthDate.year && now.month == monthDate.month;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    bool isExpanded = _expandedMonths.contains(monthKey);

    return GestureDetector(
      onTap: () => setState(() => isExpanded ? _expandedMonths.remove(monthKey) : _expandedMonths.add(monthKey)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: DottedBorder(
          color: const Color(0xFFFFD54F),
          strokeWidth: 1,
          dashPattern: const [4, 4],
          borderType: BorderType.RRect,
          radius: const Radius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFFCF0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isCurrentMonth ? 'THIS MONTH' : 'PAST MONTH', style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(DateFormat('MMMM yyyy').format(monthDate), style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.textDark)),
                        const SizedBox(width: 4),
                        Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
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
                        Text('Spent ', style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
                        Text('₹${monthTotal.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (monthSavings > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text('Saved ₹${monthSavings.toStringAsFixed(0)}', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primaryGreen)),
                      ),
                  ],
                ),
              ],
            ),
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
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No purchase history found', style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMonthlyList(Map<String, Map<DateTime, List<CartItem>>> monthlyHistory, List<String> sortedMonthKeys) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(height: 8),
              ...sortedDates.map((date) => _buildDayCard(date, days[date]!)),
            ],
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildDayCard(DateTime date, List<CartItem> items) {
    String dayKey = DateFormat('yyyy-MM-dd').format(date);
    bool isExpanded = _expandedDays.contains(dayKey);
    double dayTotal = items.fold(0.0, (sum, it) => sum + it.itemAfterVendorDiscount);
    double daySavings = items.fold(0.0, (sum, it) => sum + it.totalSavings);
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => isExpanded ? _expandedDays.remove(dayKey) : _expandedDays.add(dayKey)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('EEE, MMM d').format(date).toUpperCase(), 
                          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey[600], letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text('₹${dayTotal.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (daySavings > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Saved ₹${daySavings.toStringAsFixed(0)}', 
                            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.darkGreen)),
                        ),
                      const SizedBox(height: 12),
                      Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: Colors.grey[400], size: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, indent: 20, endIndent: 20),
            ...items.map((it) => ItemCard(
              item: it,
              isExpanded: _expandedItemId == it.id,
              onToggle: () => setState(() => _expandedItemId = _expandedItemId == it.id ? null : it.id),
              onEdit: () => _showEditModal(it),
              onDelete: () => _showDeleteConfirmation(it),
              showDate: true,
            )),
          ],
        ],
      ),
    );
  }
}
