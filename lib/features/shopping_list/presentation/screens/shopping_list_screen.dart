import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/cart_item.dart';
import '../../../../core/services/data_service.dart';
import '../widgets/add_item_modal.dart';
import '../widgets/item_card.dart';

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
        title: Text(
          'Confirm Delete',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete this item?\n\nDeleted entries cant be retrived back.',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, Keep it',
              style: GoogleFonts.dmSans(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Delete',
              style: GoogleFonts.dmSans(color: Colors.red),
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
          title: Text(
            'Delete from History?',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Do you also want to delete the entry from History tab?\n\nDeleted entries cant be retrived back.',
            style: GoogleFonts.dmSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'No, Keep it',
                style: GoogleFonts.dmSans(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Yes, Delete',
                style: GoogleFonts.dmSans(color: Colors.red),
              ),
            ),
          ],
        ),
      );

      if (deleteFromHistory == true) {
        if (mounted) dataService.removeItem(item.id);
      }
    } else {
      dataService.removeItem(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFF7F8FA),
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
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildSummaryCard() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double subtotal = dataService.subtotal;
    final double savings = dataService.totalSavings;
    final double finalTotal = dataService.finalTotalValue;
    final int savingsPercent = subtotal > 0
        ? ((savings / subtotal) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUBTOTAL & SAVINGS',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutralText,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${subtotal.toStringAsFixed(0)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (savings > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '-₹${savings.toStringAsFixed(0)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
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
              Container(width: 1, height: 30, color: Colors.grey[200]),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'FINAL TOTAL',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutralText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${finalTotal.toStringAsFixed(0)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primaryGreen,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Saved ₹${savings.toStringAsFixed(0)} today',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$savingsPercent%',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          Text(
            'Nothing in your list for this date.',
            style: GoogleFonts.dmSans(fontSize: 16, color: Colors.grey),
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
    String dateStr = DateFormat('dd MMM yyyy').format(firstDate).toUpperCase();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: groups.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateStr,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
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
            _buildCategoryHeader(categoryId, catSubtotal, items.length),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(String name, double subtotal, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _getEmojiForCategory(name),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '₹${subtotal.toStringAsFixed(0)}',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ],
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
