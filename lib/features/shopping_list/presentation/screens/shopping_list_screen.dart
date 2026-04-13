import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';
import 'package:ai_discount_calculator/core/services/data_service.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';

/// Screen displaying the current shopping list and allowing users to add/remove items.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  // Toggle for FAB position (left/right) based on long-press
  bool _fabOnRight = true;

  @override
  void initState() {
    super.initState();
    // Listen to data changes to refresh UI
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

  // Helper getters for calculating totals
  double get subtotal => dataService.currentItems.fold(
    0,
    (sum, item) => sum + (item.originalPrice ?? item.price),
  );
  double get savings => dataService.currentItems.fold(
    0,
    (sum, item) =>
        sum +
        (item.originalPrice != null ? (item.originalPrice! - item.price) : 0),
  );
  double get finalTotal => subtotal - savings;

  int _getIconCodeForName(String name) {
    final n = name.toLowerCase();
    if (n.contains(AppStrings.keywordApple)) return Icons.apple.codePoint;
    if (n.contains(AppStrings.keywordMilk) ||
        n.contains(AppStrings.keywordWater))
      return Icons.water_drop.codePoint;
    if (n.contains(AppStrings.keywordBread))
      return Icons.bakery_dining.codePoint;
    return Icons.shopping_cart.codePoint;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.background
        : AppColors.backgroundLight;
    final Color cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Summary header showing totals and savings
                _buildStickyHeader(isDark, cardColor),

                // Content Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceL,
                    vertical: AppConstants.spaceS,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.listTitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: AppConstants.fontSizeM,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                // Scrollable list area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surface.withValues(alpha: 0.1)
                          : AppColors.greyTransparent,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppConstants.borderRadiusXXL),
                      ),
                    ),
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        if (dataService.currentItems.isEmpty)
                          _buildEmptyState()
                        else
                          ..._buildItemList(isDark),

                        // Spacer for FAB visibility
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 120),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Persistent Add Button with long-press position toggle
            _buildFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state view when no items are present.
  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: AppConstants.iconSizeEmpty,
              color: AppColors.textMuted.withValues(alpha: 0.2),
            ),
            const SizedBox(height: AppConstants.spaceL),
            const Text(
              AppStrings.listEmpty,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: AppConstants.fontSizeL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the grouped list of items.
  List<Widget> _buildItemList(bool isDark) {
    final items = dataService.currentItems;
    // Group items by date (DD/MM/YYYY)
    final Map<String, List<CartItem>> groupedItems = {};
    for (var item in items) {
      final dateStr = DateFormat('dd/MM/yyyy').format(item.date);
      groupedItems.putIfAbsent(dateStr, () => []).add(item);
    }

    // Sort dates in descending order
    final sortedDates = groupedItems.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd/MM/yyyy').parse(a);
        final dateB = DateFormat('dd/MM/yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    final List<Widget> slivers = [];
    for (var date in sortedDates) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceL,
              AppConstants.spaceL,
              AppConstants.spaceL,
              8,
            ),
            child: Text(
              date,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConstants.fontSizeS,
                color: AppColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildCartItem(groupedItems[date]![index], isDark),
              childCount: groupedItems[date]!.length,
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  /// Builds the interactive FAB.
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: AppConstants.spaceL,
      left: _fabOnRight ? null : AppConstants.spaceL,
      right: _fabOnRight ? AppConstants.spaceL : null,
      child: GestureDetector(
        onLongPress: () {
          setState(() => _fabOnRight = !_fabOnRight);
          HapticFeedback.mediumImpact();
        },
        child: FloatingActionButton(
          onPressed: () => _showInputForm(),
          backgroundColor: AppColors.primaryAction,
          elevation: 6,
          child: const Icon(
            Icons.add,
            color: AppColors.white,
            size: AppConstants.iconSizeXL - 2,
          ),
        ),
      ),
    );
  }

  /// Handles the delete confirmation flow.
  void _confirmDeleteItem(String id) async {
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
      final bool inHistory = dataService.checkItemInHistory(id);
      bool alsoDeleteHistory = false;

      if (inHistory) {
        final bool? deleteHistory = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(AppStrings.listDeleteFromHistoryTitle),
            content: const Text(AppStrings.listDeleteFromHistoryMsg),
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
        alsoDeleteHistory = deleteHistory ?? false;
      }

      dataService.removeItem(id, alsoFromHistory: alsoDeleteHistory);
    }
  }

  /// Displays the modal bottom sheet for adding or editing items.
  void _showInputForm({CartItem? itemToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemModal(
        editItem: itemToEdit,
        onItemAdded: (name, qty, unit, unitPrice, discount, isPercent, date) {
          _processAddItem(
            name,
            qty,
            unit,
            unitPrice,
            discount,
            isPercent,
            date: date,
            editingId: itemToEdit?.id,
          );
        },
      ),
    );
  }

  /// Processes raw input into a CartItem and adds or updates it in the database.
  void _processAddItem(
    String name,
    double qty,
    String unit,
    double unitPrice,
    double discount,
    bool isPercent, {
    DateTime? date,
    String? editingId,
  }) {
    double totalOriginalPrice = unitPrice * qty;
    double finalPrice = totalOriginalPrice;
    String? discountLabel;
    double? originalPriceForRecord;

    // Calculate discount based on type (percentage or fixed amount)
    if (isPercent) {
      if (discount > 0) {
        originalPriceForRecord = totalOriginalPrice;
        finalPrice =
            totalOriginalPrice *
            (1 - discount / AppConstants.maxDiscountPercent);
        discountLabel =
            "${discount.toStringAsFixed(0)}${AppStrings.calcPercentSymbol} ${AppStrings.listOffLabel}";
      }
    } else {
      if (discount > 0) {
        originalPriceForRecord = totalOriginalPrice;
        finalPrice = totalOriginalPrice - discount;
        discountLabel =
            "${AppStrings.calcRupeeSymbol}${discount.toStringAsFixed(0)} ${AppStrings.listOffLabel}";
      }
    }

    // Add or Update in DataService
    final newItem = CartItem(
      id: editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      qty: "${qty.toString().replaceAll(RegExp(r'\.0$'), '')} $unit",
      price: finalPrice,
      originalPrice: originalPriceForRecord,
      discountLabel: discountLabel,
      iconCode: _getIconCodeForName(name),
      date: date ?? DateTime.now(),
      unitPrice: unitPrice,
      rawQty: qty,
      unit: unit,
      discountValue: discount,
      isPercent: isPercent,
    );

    if (editingId != null) {
      dataService.updateItem(newItem);
    } else {
      dataService.addItem(newItem);
    }
  }

  /// Builds the summary header showing current list financial status.
  Widget _buildStickyHeader(bool isDark, Color cardColor) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceL),
      padding: const EdgeInsets.all(AppConstants.spaceXL),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXXL - 12),
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.accentMuted,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.listSubtotalSavings,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceS),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        "${AppStrings.calcRupeeSymbol}${subtotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceS),
                      Text(
                        "-${AppStrings.calcRupeeSymbol}${savings.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: AppConstants.fontSizeL,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.accentMuted),
          const SizedBox(width: AppConstants.spaceL),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  AppStrings.listFinalTotal,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeS,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXS),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "${AppStrings.calcRupeeSymbol}${finalTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeL + 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAction,
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

  /// Builds an individual cart item row.
  Widget _buildCartItem(CartItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spaceM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spaceL),
            child: Row(
              children: [
                // Item Icon
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  decoration: BoxDecoration(
                    color: AppColors.primaryList.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusL,
                    ),
                  ),
                  child: Icon(
                    IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                    color: AppColors.primaryList,
                    size: AppConstants.iconSizeL,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceL),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.fontSizeL,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.qty,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: AppConstants.fontSizeM,
                        ),
                      ),
                    ],
                  ),
                ),

                // Pricing & Discounts
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.discountLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusS,
                          ),
                        ),
                        child: Text(
                          item.discountLabel!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: AppConstants.fontSizeXS,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      "${AppStrings.calcRupeeSymbol}${item.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeXL,
                        color: AppColors.primaryAction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: AppConstants.spaceXXL + 4,
                ), // Buffer for icons at edge
              ],
            ),
          ),

          // Edit Icon (Top Right Corner Border)
          Positioned(
            top: -5,
            right: -5,
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.primaryList,
                size: AppConstants.iconSizeS + 2,
              ),
              onPressed: () => _showInputForm(itemToEdit: item),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ),

          // Delete Icon (Bottom Right Corner Border)
          Positioned(
            bottom: -5,
            right: -5,
            child: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: AppConstants.iconSizeS + 4,
              ),
              onPressed: () => _confirmDeleteItem(item.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal widget for inputting new item details.
class AddItemModal extends StatefulWidget {
  final CartItem? editItem;
  final Function(
    String name,
    double qty,
    String unit,
    double unitPrice,
    double discount,
    bool isPercent,
    DateTime date,
  )
  onItemAdded;

  const AddItemModal({super.key, this.editItem, required this.onItemAdded});

  @override
  State<AddItemModal> createState() => AddItemModalState();
}

class AddItemModalState extends State<AddItemModal> {
  // Input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  // Focus nodes for highlighting and navigation
  final FocusNode _nameNode = FocusNode();
  final FocusNode _qtyNode = FocusNode();
  final FocusNode _priceNode = FocusNode();
  final FocusNode _disNode = FocusNode();

  String _selectedUnit = AppStrings.listSelectUnit;
  DateTime _selectedDate = DateTime.now();
  bool _isPercent = true;
  bool _canAdd = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validate);
    _qtyController.addListener(_validate);
    _priceController.addListener(_validate);
    _discountController.addListener(_validate);

    _nameNode.addListener(_updateUI);
    _qtyNode.addListener(_updateUI);
    _priceNode.addListener(_updateUI);
    _disNode.addListener(_updateUI);

    // Pre-fill if editing
    if (widget.editItem != null) {
      final item = widget.editItem!;
      _nameController.text = item.title;
      _qtyController.text =
          item.rawQty?.toString().replaceAll(RegExp(r'\.0$'), '') ?? "";
      _selectedUnit = item.unit ?? AppStrings.listSelectUnit;
      _priceController.text =
          item.unitPrice?.toString().replaceAll(RegExp(r'\.0$'), '') ?? "";
      _discountController.text =
          item.discountValue?.toString().replaceAll(RegExp(r'\.0$'), '') ?? "";
      _isPercent = item.isPercent ?? true;
      _selectedDate = item.date;
      _canAdd = true;
    }

    // Auto-focus name field on open if not editing
    if (widget.editItem == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _nameNode.requestFocus(),
      );
    }
  }

  void _updateUI() => setState(() {});

  /// Validates the form input and enables/disables the add button.
  void _validate() {
    final name = _nameController.text.trim();
    final qty = _qtyController.text.trim();
    final price = _priceController.text.trim();
    bool valid =
        name.isNotEmpty &&
        qty.isNotEmpty &&
        price.isNotEmpty &&
        _selectedUnit != AppStrings.listSelectUnit;
    if (valid != _canAdd) setState(() => _canAdd = valid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _nameNode.dispose();
    _qtyNode.dispose();
    _priceNode.dispose();
    _disNode.dispose();
    super.dispose();
  }

  /// Final validation and submission of the new item.
  void _submit() {
    if (!_canAdd) return;

    final name = _nameController.text.trim();
    final qty = double.tryParse(_qtyController.text.trim()) ?? 1.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;

    if (price <= 0) {
      setState(() => _errorMsg = AppStrings.errorEnterPrice);
      return;
    }

    if (_isPercent && discount >= 100) {
      setState(() => _errorMsg = AppStrings.errorDiscountPercentLimit);
      return;
    }

    if (!_isPercent && discount >= (price * qty)) {
      setState(() => _errorMsg = AppStrings.errorDiscountAmountLimit);
      return;
    }

    widget.onItemAdded(
      name,
      qty,
      _selectedUnit,
      price,
      discount,
      _isPercent,
      _selectedDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
    Color bgColor = isDark ? AppColors.background : AppColors.backgroundLight;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spaceXXL,
          AppConstants.spaceM,
          AppConstants.spaceXXL,
          AppConstants.spaceXXL + 8,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.borderRadiusXXL),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.editItem != null
                    ? AppStrings.listEditItem
                    : AppStrings.listTitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: AppConstants.fontSizeL,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryAction,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppConstants.spaceM),
              // Handle for dragging modal
              Container(
                width: 40,
                height: AppConstants.spaceXS,
                margin: const EdgeInsets.only(bottom: AppConstants.spaceXL),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      AppStrings.listItemName,
                      _nameController,
                      AppStrings.listItemHint,
                      isDark,
                      bgColor,
                      node: _nameNode,
                      isText: true,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(child: _buildDatePickerField(isDark, bgColor)),
                ],
              ),
              const SizedBox(height: AppConstants.spaceL),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      AppStrings.listQty,
                      _qtyController,
                      AppStrings.listQtyHint,
                      isDark,
                      bgColor,
                      node: _qtyNode,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(child: _buildDropdown(isDark, bgColor)),
                ],
              ),
              const SizedBox(height: AppConstants.spaceL),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      AppStrings.listUnitPrice,
                      _priceController,
                      AppStrings.listPriceHint,
                      isDark,
                      bgColor,
                      node: _priceNode,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        _buildField(
                          AppStrings.listDiscount,
                          _discountController,
                          AppStrings.listDiscountHint,
                          isDark,
                          bgColor,
                          node: _disNode,
                        ),
                        Positioned(right: 8, bottom: 8, child: _buildToggle()),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceXXL),

              // Error feedback
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeM,
                    ),
                  ),
                ),

              // Submit Action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canAdd ? _submit : null,
                  icon: Icon(
                    widget.editItem != null ? Icons.save : Icons.add_circle,
                    color: AppColors.white,
                  ),
                  label: Text(
                    widget.editItem != null
                        ? AppStrings.listUpdate
                        : AppStrings.listAddToList,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppConstants.fontSizeL,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canAdd
                        ? AppColors.primaryAction
                        : Colors.grey.shade400,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.spaceL,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusL,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceL),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  AppStrings.listCancel,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for building stylized text fields.
  Widget _buildField(
    String label,
    TextEditingController ctrl,
    String hint,
    bool isDark,
    Color bgColor, {
    required FocusNode node,
    bool isText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => node.requestFocus(),
          child: AnimatedContainer(
            duration: AppConstants.animationDurationSmall,
            height: isText ? null : AppConstants.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceL,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              border: Border.all(
                color: node.hasFocus
                    ? AppColors.primaryList
                    : (isDark
                          ? AppColors.white.withValues(alpha: 0.05)
                          : AppColors.accentMuted),
                width: node.hasFocus ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: ctrl,
              focusNode: node,
              keyboardType: isText
                  ? TextInputType.multiline
                  : TextInputType.number,
              maxLines: isText ? null : 1,
              maxLength: isText
                  ? AppConstants.itemNameMaxLength
                  : AppConstants.maxInputDigits,
              inputFormatters: isText
                  ? null
                  : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                counterText: "",
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper for building date picker field for selecting entry date.
  Widget _buildDatePickerField(bool isDark, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DATE",
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: isDark
                      ? const ColorScheme.dark(primary: AppColors.primaryList)
                      : const ColorScheme.light(primary: AppColors.primaryList),
                ),
                child: child!,
              ),
            );
            if (!mounted) return;
            if (picked != null) setState(() => _selectedDate = picked);
          },
          child: Container(
            height: AppConstants.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceL,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              border: Border.all(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.05)
                    : AppColors.accentMuted,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDark ? Colors.white70 : AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Helper for building the unit selection dropdown.
  Widget _buildDropdown(bool isDark, Color bgColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.listUnitType,
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: AppConstants.fieldHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.accentMuted,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnit,
              isExpanded: true,
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
              items: AppStrings.unitOptions
                  .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedUnit = val);
                _validate();
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Helper for building the discount type toggle percentage vs currency.
  Widget _buildToggle() {
    return Container(
      width: AppConstants.toggleWidth,
      height: AppConstants.toggleHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: AppConstants.spaceXS),
        ],
      ),
      child: Column(
        children: [
          _togglePart(
            AppStrings.calcPercentSymbol,
            _isPercent,
            true,
            () => setState(() => _isPercent = true),
          ),
          _togglePart(
            AppStrings.calcRupeeSymbol,
            !_isPercent,
            false,
            () => setState(() => _isPercent = false),
          ),
        ],
      ),
    );
  }

  Widget _togglePart(String txt, bool act, bool top, VoidCallback tap) {
    return Expanded(
      child: GestureDetector(
        onTap: tap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: act ? AppColors.primaryAction : Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: top
                  ? const Radius.circular(AppConstants.borderRadiusS)
                  : Radius.zero,
              bottom: !top
                  ? const Radius.circular(AppConstants.borderRadiusS)
                  : Radius.zero,
            ),
          ),
          child: Text(
            txt,
            style: TextStyle(
              fontSize: AppConstants.toggleFontSize,
              fontWeight: FontWeight.bold,
              color: act ? AppColors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
