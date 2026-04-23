import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';
import 'package:ai_discount_calculator/core/services/data_service.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';
import 'package:ai_discount_calculator/core/models/category_group.dart';

/// Screen displaying the current shopping list and allowing users to add/remove items.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
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

  // Note: Totals are now handled by DataService to support category-level discounts.

  int _getIconCodeForName(String name) {
    final n = name.toLowerCase();
    if (n.contains(AppStrings.keywordApple)) return Icons.apple.codePoint;
    if (n.contains(AppStrings.keywordMilk) ||
        n.contains(AppStrings.keywordWater)) {
      return Icons.water_drop.codePoint;
    }
    if (n.contains(AppStrings.keywordBread)) {
      return Icons.bakery_dining.codePoint;
    }
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
                        if (dataService.currentItems.isNotEmpty)
                          SliverToBoxAdapter(child: _buildStoreOfferBanner()),
                          
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

  /// Builds the grouped list of items by Category.
  List<Widget> _buildItemList(bool isDark) {
    final groupedItems = dataService.groupItemsByCategory();
    final sortedCategoryIds = groupedItems.keys.toList();

    final List<Widget> slivers = [];
    for (var catId in sortedCategoryIds) {
      final category = dataService.getCategoryById(catId);
      final items = groupedItems[catId]!;
      
      double catSubtotal = items.fold(0, (sum, it) => sum + it.price);
      double afterRoundOff = catSubtotal - category.vendorRoundOff;
      double finalCatTotal = afterRoundOff * (1 - category.storeOfferPercent / 100);

      slivers.add(
        SliverToBoxAdapter(
          child: _buildCategoryHeader(category, catSubtotal, finalCatTotal, isDark),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCartItem(items[index], isDark),
              childCount: items.length,
            ),
          ),
        ),
      );
    }
    return slivers;
  }

  Widget _buildCategoryHeader(CategoryGroup cat, double subtotal, double total, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceL, AppConstants.spaceL, AppConstants.spaceL, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showCategorySettings(cat),
                child: Row(
                  children: [
                    Text(
                      cat.name.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppConstants.fontSizeS + 2,
                        color: AppColors.primaryAction,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.settings, size: 14, color: AppColors.primaryAction),
                  ],
                ),
              ),
              Text(
                "Subtotal: ₹${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: AppConstants.fontSizeS,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (cat.vendorRoundOff > 0 || cat.storeOfferPercent > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  if (cat.vendorRoundOff > 0)
                    _buildTinyTag("Round-off: -₹${cat.vendorRoundOff.toStringAsFixed(0)}", Colors.blue),
                  if (cat.vendorRoundOff > 0 && cat.storeOfferPercent > 0) const SizedBox(width: 8),
                  if (cat.storeOfferPercent > 0)
                    _buildTinyTag("Store Offer: ${cat.storeOfferPercent.toStringAsFixed(0)}%", Colors.orange),
                  const Spacer(),
                  Text(
                    "Shop Total: ₹${total.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeS + 2,
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildTinyTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStoreOfferBanner() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceL),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade700]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "SUPER MALL OFFER ACTIVE: Extra discounts applied on category subtotals!",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySettings(CategoryGroup cat) {
    final TextEditingController roundOffController = TextEditingController(text: cat.vendorRoundOff.toString());
    final TextEditingController offerController = TextEditingController(text: cat.storeOfferPercent.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Shop Settings: ${cat.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roundOffController,
              decoration: const InputDecoration(labelText: "Vendor Round-off (₹)", hintText: "e.g. 3"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: offerController,
              decoration: const InputDecoration(labelText: "Store Offer (%)", hintText: "e.g. 5"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updated = cat.copyWith(
                vendorRoundOff: double.tryParse(roundOffController.text) ?? 0,
                storeOfferPercent: double.tryParse(offerController.text) ?? 0,
              );
              dataService.updateCategoryGroup(updated);
              Navigator.pop(ctx);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
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
        onItemAdded: (name, qty, unit, unitPrice, discount, discountType, priceMode, catId, date) {
          _processAddItem(
            name,
            qty,
            unit,
            unitPrice,
            discount,
            discountType,
            priceMode,
            catId,
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
    DiscountType discountType,
    PriceMode priceMode,
    String categoryId, {
    DateTime? date,
    String? editingId,
  }) {
    double totalOriginalPrice;
    
    if (priceMode == PriceMode.flat) {
      totalOriginalPrice = unitPrice;
    } else {
      totalOriginalPrice = unitPrice * qty;
    }

    double finalPrice = totalOriginalPrice;
    String? discountLabel;
    double? originalPriceForRecord;

    // Calculate discount based on type (percentage or flat amount)
    if (discountType == DiscountType.percentage) {
      if (discount > 0) {
        originalPriceForRecord = totalOriginalPrice;
        finalPrice = totalOriginalPrice * (1 - discount / 100);
        discountLabel = "${discount.toStringAsFixed(0)}% OFF";
      }
    } else {
      if (discount > 0) {
        originalPriceForRecord = totalOriginalPrice;
        finalPrice = totalOriginalPrice - discount;
        discountLabel = "₹${discount.toStringAsFixed(0)} OFF";
      }
    }

    // Add or Update in DataService
    final newItem = CartItem(
      id: editingId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: name,
      qty: priceMode == PriceMode.flat ? unit : "${qty.toString().replaceAll(RegExp(r'\.0$'), '')} $unit",
      price: finalPrice,
      originalPrice: originalPriceForRecord,
      discountLabel: discountLabel,
      iconCode: _getIconCodeForName(name),
      date: date ?? DateTime.now(),
      priceMode: priceMode,
      categoryId: categoryId,
      discountType: discountType,
      discountValue: discount,
      unitPrice: unitPrice,
      rawQty: qty,
      unit: unit,
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "GROSS SUB-TOTAL",
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
                      child: Text(
                        "${AppStrings.calcRupeeSymbol}${dataService.totalItemsSubtotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeXXL,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
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
                      "GRAND TOTAL",
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
                        "${AppStrings.calcRupeeSymbol}${dataService.finalTotalValue.toStringAsFixed(2)}",
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
          const SizedBox(height: AppConstants.spaceM),
          const Divider(height: 1),
          const SizedBox(height: AppConstants.spaceS),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryDetail("Item Discounts", "-₹${dataService.totalItemDiscounts.toStringAsFixed(0)}", AppColors.success),
              _buildSummaryDetail("Round-offs", "-₹${dataService.totalVendorRoundOffs.toStringAsFixed(0)}", Colors.blue),
              _buildSummaryDetail("Store Offers", "-₹${dataService.totalStoreOffers.toStringAsFixed(0)}", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDetail(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
        ),
      ],
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
    DiscountType discountType,
    PriceMode priceMode,
    String categoryId,
    DateTime date,
  ) onItemAdded;

  const AddItemModal({super.key, this.editItem, required this.onItemAdded});

  @override
  State<AddItemModal> createState() => AddItemModalState();
}

class AddItemModalState extends State<AddItemModal> {
  // Input controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController(text: "1");
  final TextEditingController _priceController = TextEditingController(); // This will be "Item Rate"
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _customUnitController = TextEditingController();

  // Focus nodes
  final FocusNode _nameNode = FocusNode();
  final FocusNode _qtyNode = FocusNode();
  final FocusNode _priceNode = FocusNode();
  final FocusNode _disNode = FocusNode();

  String _selectedUnit = 'Piece';
  String _selectedCategoryId = 'veggies';
  DateTime _selectedDate = DateTime.now();
  DiscountType _discountType = DiscountType.percentage;
  PriceMode _priceMode = PriceMode.perUnit;
  bool _isCustomCategory = false;
  bool _isCustomUnit = false;
  
  bool _canAdd = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    if (widget.editItem != null) {
      final item = widget.editItem!;
      _nameController.text = item.title;
      _qtyController.text = item.rawQty.toString().replaceAll(RegExp(r'\.0$'), '');
      _selectedUnit = item.unit;
      _selectedCategoryId = item.categoryId;
      _priceController.text = item.unitPrice.toString().replaceAll(RegExp(r'\.0$'), '');
      _discountController.text = item.discountValue.toString().replaceAll(RegExp(r'\.0$'), '');
      _discountType = item.discountType;
      _priceMode = item.priceMode;
      _selectedDate = item.date;
      _canAdd = true;
    }

    if (widget.editItem == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _nameNode.requestFocus());
    }
  }

  void _updateUI() => setState(() {});

  /// Validates the form input and enables/disables the add button.
  void _validate() {
    final name = _nameController.text.trim();
    final qty = _qtyController.text.trim();
    final price = _priceController.text.trim();
    bool valid = name.isNotEmpty && qty.isNotEmpty && price.isNotEmpty;
    if (valid != _canAdd) setState(() => _canAdd = valid);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _customCategoryController.dispose();
    _customUnitController.dispose();
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

    if (_discountType == DiscountType.percentage && discount >= 100) {
      setState(() => _errorMsg = AppStrings.errorDiscountPercentLimit);
      return;
    }

    double totalVal;
    if (_priceMode == PriceMode.flat) {
      totalVal = price;
    } else {
      totalVal = price * qty;
    }

    if (_discountType == DiscountType.amount && discount >= totalVal) {
      setState(() => _errorMsg = AppStrings.errorDiscountAmountLimit);
      return;
    }

    final finalCategory = _isCustomCategory ? _customCategoryController.text.trim() : _selectedCategoryId;
    final finalUnit = _isCustomUnit ? _customUnitController.text.trim() : _selectedUnit;

    widget.onItemAdded(
      name,
      qty,
      finalUnit.isEmpty ? "unit" : finalUnit,
      price,
      discount,
      _discountType,
      _priceMode,
      finalCategory,
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

              // 1. Date Bar (Moved from main screen)
              _buildModernDateBar(isDark),
              const SizedBox(height: AppConstants.spaceL),

              // 2. Category Selector
              _buildCategoryChips(isDark, bgColor),
              const SizedBox(height: AppConstants.spaceL),

              _buildField(
                AppStrings.listItemName,
                _nameController,
                AppStrings.listItemHint,
                isDark,
                bgColor,
                node: _nameNode,
                isText: true,
              ),
              const SizedBox(height: AppConstants.spaceL),

              // 3. Rate Mode Radio Buttons
              _buildPriceModeRadio(isDark),
              const SizedBox(height: AppConstants.spaceL),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildField(
                      "ITEM RATE (₹)",
                      _priceController,
                      "e.g. 70",
                      isDark,
                      bgColor,
                      node: _priceNode,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceM),
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
                ],
              ),
              const SizedBox(height: AppConstants.spaceL),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "FIXED DISCOUNT",
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeS,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            _buildField(
                              "",
                              _discountController,
                              "0",
                              isDark,
                              bgColor,
                              node: _disNode,
                              showLabel: false,
                            ),
                            Positioned(right: 8, bottom: 8, child: _buildToggle()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceL),
              _buildQuickUnits(isDark, bgColor),
              
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
    bool showLabel = true,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeS,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
        if (showLabel) const SizedBox(height: 6),
        GestureDetector(
          onTap: () => enabled ? node.requestFocus() : null,
          child: AnimatedContainer(
            duration: AppConstants.animationDurationSmall,
            height: isText ? null : AppConstants.fieldHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceL,
            ),
            decoration: BoxDecoration(
              color: enabled ? bgColor : (isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
              border: Border.all(
                color: node.hasFocus && enabled
                    ? AppColors.primaryList
                    : (isDark
                          ? AppColors.white.withValues(alpha: 0.05)
                          : AppColors.accentMuted),
                width: node.hasFocus && enabled ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: ctrl,
              focusNode: node,
              enabled: enabled,
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
            _discountType == DiscountType.percentage,
            true,
            () => setState(() => _discountType = DiscountType.percentage),
          ),
          _togglePart(
            AppStrings.calcRupeeSymbol,
            _discountType == DiscountType.amount,
            false,
            () => setState(() => _discountType = DiscountType.amount),
          ),
        ],
      ),
    );
  }

  /// Modern date bar moved from the main screen into the modal.
  Widget _buildModernDateBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            setState(() => _selectedDate = picked);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.primaryAction),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, y').format(_selectedDate),
              style: GoogleFonts.spaceGrotesk(
                fontSize: AppConstants.fontSizeM,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(bool isDark, Color bgColor) {
    final defaultCats = [
      {'id': 'milk', 'name': 'Milk'},
      {'id': 'veggies', 'name': 'Veggies'},
      {'id': 'grocery', 'name': 'Grocery'},
      {'id': 'custom', 'name': 'Custom'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CATEGORY",
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: defaultCats.map((cat) {
            final isCustomTab = cat['id'] == 'custom';
            final isSelected = _isCustomCategory ? isCustomTab : _selectedCategoryId == cat['id'];

            return GestureDetector(
              onTap: () {
                if (isCustomTab) {
                  setState(() => _isCustomCategory = true);
                } else {
                  setState(() {
                    _isCustomCategory = false;
                    _selectedCategoryId = cat['id']!;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                constraints: BoxConstraints(minWidth: isCustomTab ? 100 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryAction : (isDark ? AppColors.cardDark : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isCustomTab && _isCustomCategory
                    ? IntrinsicWidth(
                        child: TextField(
                          controller: _customCategoryController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: "Shop Name",
                            hintStyle: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      )
                    : Text(
                        isCustomTab && _customCategoryController.text.isNotEmpty 
                            ? _customCategoryController.text 
                            : cat['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceModeRadio(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "RATE MODE",
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _radioOption("Flat Rate", PriceMode.flat),
            const SizedBox(width: AppConstants.spaceL),
            _radioOption("Per Unit", PriceMode.perUnit),
          ],
        ),
      ],
    );
  }

  Widget _radioOption(String label, PriceMode mode) {
    final isSelected = _priceMode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _priceMode = mode;
        _validate();
      }),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<PriceMode>(
            value: mode,
            groupValue: _priceMode,
            onChanged: (val) => setState(() {
              _priceMode = val!;
              _validate();
            }),
            activeColor: AppColors.primaryAction,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryAction : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickUnits(bool isDark, Color bgColor) {
    final units = ['Gram', 'Kg', 'Ltr', 'ML', 'Dozen', 'Piece', 'Packet', 'Custom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "QUANTITY UNIT",
          style: TextStyle(
            fontSize: AppConstants.fontSizeS,
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: units.map((u) {
            final isCustomTab = u == 'Custom';
            final isSelected = _isCustomUnit ? isCustomTab : _selectedUnit == u;

            return GestureDetector(
              onTap: () {
                if (isCustomTab) {
                  setState(() => _isCustomUnit = true);
                } else {
                  setState(() {
                    _isCustomUnit = false;
                    _selectedUnit = u;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                constraints: BoxConstraints(minWidth: isCustomTab ? 80 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryList : bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryList : (isDark ? Colors.white10 : Colors.grey.shade300),
                  ),
                ),
                child: isCustomTab && _isCustomUnit
                    ? IntrinsicWidth(
                        child: TextField(
                          controller: _customUnitController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: "Unit",
                            hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      )
                    : Text(
                        isCustomTab && _customUnitController.text.isNotEmpty 
                            ? _customUnitController.text 
                            : u,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
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
