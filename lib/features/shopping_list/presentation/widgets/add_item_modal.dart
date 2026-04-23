import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/cart_item.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/custom_dropdowns.dart';

class AddItemModal extends StatefulWidget {
  final CartItem? editItem;
  final Function(CartItem item) onItemAdded;

  const AddItemModal({super.key, this.editItem, required this.onItemAdded});

  @override
  State<AddItemModal> createState() => _AddItemModalState();
}

class _AddItemModalState extends State<AddItemModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _flatAmountController = TextEditingController();
  final TextEditingController _flatQtyController = TextEditingController(text: '1');
  
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _baseQtyController = TextEditingController(text: '1');
  final TextEditingController _boughtQtyController = TextEditingController();
  
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _vendorDiscountController = TextEditingController();

  PriceMode _priceMode = PriceMode.flatRate;
  String _selectedCategory = '';
  String _selectedBaseUnit = 'kg';
  String _selectedBoughtUnit = 'g';
  DiscountType _itemDiscountType = DiscountType.percentage;
  DiscountType _vendorDiscountType = DiscountType.flat;
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String _marketType = 'Local'; 
  
  @override
  void initState() {
    super.initState();
    if (widget.editItem != null) {
      final it = widget.editItem!;
      _nameController.text = it.itemName;
      _selectedCategory = it.categoryId;
      _priceMode = it.priceMode;
      _selectedDate = DateTime(it.date.year, it.date.month, it.date.day);
      _marketType = it.marketType;

      if (_priceMode == PriceMode.flatRate) {
        _flatAmountController.text = it.enteredAmount.toString().replaceAll(RegExp(r'\.0$'), '');
        _flatQtyController.text = it.boughtQty.toString().replaceAll(RegExp(r'\.0$'), '');
        _selectedBoughtUnit = it.boughtUnit;
      } else {
        _basePriceController.text = it.enteredAmount.toString().replaceAll(RegExp(r'\.0$'), '');
        _baseQtyController.text = it.baseQty.toString().replaceAll(RegExp(r'\.0$'), '');
        _selectedBaseUnit = it.baseUnit;
        _boughtQtyController.text = it.boughtQty.toString().replaceAll(RegExp(r'\.0$'), '');
        _selectedBoughtUnit = it.boughtUnit;
      }
      _discountController.text = it.discountValue > 0 ? it.discountValue.toString().replaceAll(RegExp(r'\.0$'), '') : '';
      _itemDiscountType = it.discountType;
      _vendorDiscountController.text = it.vendorDiscountValue > 0 ? it.vendorDiscountValue.toString().replaceAll(RegExp(r'\.0$'), '') : '';
      _vendorDiscountType = it.vendorDiscountType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _flatAmountController.dispose();
    _flatQtyController.dispose();
    _basePriceController.dispose();
    _baseQtyController.dispose();
    _boughtQtyController.dispose();
    _discountController.dispose();
    _vendorDiscountController.dispose();
    DropdownManager.dismiss();
    super.dispose();
  }

  String _getUnitFamily(String unit) {
    if (unit == 'g' || unit == 'kg') return 'Weight';
    if (unit == 'ml' || unit == 'ltr') return 'Volume';
    return 'Count';
  }

  bool get _isUnitMismatch {
    if (_priceMode == PriceMode.flatRate) return false;
    return _getUnitFamily(_selectedBaseUnit) != _getUnitFamily(_selectedBoughtUnit);
  }

  bool get _isValid {
    if (_selectedCategory.isEmpty) return false;
    if (_nameController.text.trim().isEmpty) return false;
    if (_isUnitMismatch) return false;
    
    if (_priceMode == PriceMode.flatRate) {
       return _flatAmountController.text.isNotEmpty && _flatQtyController.text.isNotEmpty;
    } else {
       return _basePriceController.text.isNotEmpty && _baseQtyController.text.isNotEmpty && _boughtQtyController.text.isNotEmpty;
    }
  }

  CartItem _calculateTempItem() {
    double enteredAmount = double.tryParse(_priceMode == PriceMode.flatRate ? _flatAmountController.text : _basePriceController.text) ?? 0;
    double baseQty = double.tryParse(_priceMode == PriceMode.flatRate ? _flatQtyController.text : _baseQtyController.text) ?? 1;
    double boughtQty = double.tryParse(_priceMode == PriceMode.flatRate ? _flatQtyController.text : _boughtQtyController.text) ?? 1;
    
    return CartItem(
      id: widget.editItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: _nameController.text,
      quantity: "${boughtQty.toString().replaceAll(RegExp(r'\.0$'), '')}$_selectedBoughtUnit",
      unitType: _getUnitFamily(_selectedBoughtUnit),
      priceMode: _priceMode,
      enteredAmount: enteredAmount,
      baseQty: baseQty,
      baseUnit: _selectedBaseUnit,
      boughtQty: boughtQty,
      boughtUnit: _selectedBoughtUnit,
      discountValue: double.tryParse(_discountController.text) ?? 0,
      discountType: _itemDiscountType,
      categoryId: _selectedCategory,
      date: _selectedDate,
      vendorDiscountValue: double.tryParse(_vendorDiscountController.text) ?? 0,
      vendorDiscountType: _vendorDiscountType,
      iconCode: widget.editItem?.iconCode ?? 0xe59c,
      marketType: _marketType,
    );
  }

  void _submit() {
    if (!_isValid) return;
    final item = _calculateTempItem();
    widget.onItemAdded(item);
    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempItem = _calculateTempItem();

    return SafeArea(
      bottom: false, // Handled by viewInsets padding
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(widget.editItem != null ? 'EDIT ITEM' : 'ADD ITEM', style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
            const SizedBox(height: 20),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDatePickerChip(),
                    const SizedBox(height: 20),
                    
                    _buildSectionLabel('ITEM NAME'),
                    _buildTextInput(_nameController, 'Enter item name...'),
                    const SizedBox(height: 20),
  
                    _buildSectionLabel('CATEGORY'),
                    CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (name, emoji) => setState(() => _selectedCategory = name),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildMarketSwitch(),
                    const SizedBox(height: 20),
                    
                    _buildSectionLabel('PRICE MODE'),
                    _buildPriceModeToggle(),
                    const SizedBox(height: 20),
                    
                    if (_priceMode == PriceMode.flatRate) _buildFlatRateFields() else _buildPerUnitFields(),
                    
                    if (_isUnitMismatch) _buildUnitMismatchWarning(),
                    const SizedBox(height: 20),
                    
                    _buildSectionLabel('ITEM DISCOUNT'),
                    _buildDiscountInput(),
                    const SizedBox(height: 20),
                    
                    _buildItemTotalCard(tempItem),
                    const SizedBox(height: 12),
                    
                    _buildVendorDiscountRow(),
                    if (tempItem.vendorDiscountValue > 0) ...[
                      const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('after vendor discount', style: TextStyle(fontSize: 12, color: Colors.grey)))),
                      _buildFinalTotalCard(tempItem),
                    ],
                    
                    const SizedBox(height: 30),
                    _buildAddButton(),
                    const SizedBox(height: 30), // Extra bottom spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerChip() {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    bool isToday = _selectedDate.isAtSameMomentAs(today);
    String dateStr = isToday ? "TODAY" : DateFormat('dd MMM yyyy').format(_selectedDate).toUpperCase();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 20, color: isDark ? Colors.white : AppColors.textDark),
              const SizedBox(width: 10),
              Text(
                "$dateStr (Tap to change)",
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketSwitch() {
    bool isMall = _marketType == 'Mall';
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMarketOption('Local Market', '🏘️', !isMall)),
          Expanded(child: _buildMarketOption('Super Mall', '🏢', isMall)),
        ],
      ),
    );
  }

  Widget _buildMarketOption(String label, String icon, bool active) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _marketType = label.contains('Local') ? 'Local' : 'Mall'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? (isDark ? AppColors.darkGreen : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active && !isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: active ? (isDark ? Colors.white : AppColors.textDark) : AppColors.neutralText)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.neutralText, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: AppColors.neutralText.withValues(alpha: 0.4)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPriceModeToggle() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton(PriceMode.flatRate, '💰', 'Flat Rate', 'Total Amount')),
          Expanded(child: _buildToggleButton(PriceMode.perUnit, '📐', 'Per Unit', 'Rate per kg/ltr')),
        ],
      ),
    );
  }

  Widget _buildToggleButton(PriceMode mode, String icon, String title, String hint) {
    bool isSelected = _priceMode == mode;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _priceMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (isDark ? AppColors.darkGreen : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected && !isDark ? [const BoxShadow(color: Color(0x0D000000), blurRadius: 4)] : null,
        ),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.5,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(icon), const SizedBox(width: 4), Text(title, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 13))]),
              Text(hint, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.neutralText)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlatRateFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRateInput(_flatQtyController, 'Qty', isMono: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildRateInput(_flatAmountController, 'Amount', prefix: '₹', isMono: true)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['pcs', 'g', 'kg', 'ml', 'ltr', 'tin', 'dzn', 'pair', 'pkt', 'mtr', 'ft', 'cm', 'galn']
              .map((u) => _buildSmallUnitChip(u)).toList(),
        ),
      ],
    );
  }

  Widget _buildSmallUnitChip(String u) {
    bool isSelected = _selectedBoughtUnit == u;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selectedBoughtUnit = u),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueTint : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: isSelected ? AppColors.blueBorder : Colors.transparent, width: 1.5),
        ),
        child: Text(u, style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? AppColors.blueText : AppColors.neutralText)),
      ),
    );
  }

  Widget _buildPerUnitFields() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        children: [
          _buildPerUnitInnerRow(
            label: 'VENDOR RATE',
            child: Row(
              children: [
                Text('₹', style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.neutralText)),
                const SizedBox(width: 8),
                Expanded(child: _buildRateInput(_basePriceController, '0', isMono: true, fontSize: 15)),
                const SizedBox(width: 8),
                Text('per', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.neutralText)),
                const SizedBox(width: 8),
                SizedBox(width: 38, child: _buildRateInput(_baseQtyController, '1', isMono: true, fontSize: 13)),
                const SizedBox(width: 8),
                UnitPickerPill(
                  unit: _selectedBaseUnit,
                  isGreen: true,
                  onUnitSelected: (u) => setState(() => _selectedBaseUnit = u),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, color: AppColors.borderDefault),
          ),
          _buildPerUnitInnerRow(
            label: 'YOU BOUGHT',
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildRateInput(_boughtQtyController, '0', isMono: true, fontSize: 13)),
                const SizedBox(width: 8),
                UnitPickerPill(
                  unit: _selectedBoughtUnit,
                  isGreen: false,
                  isError: _isUnitMismatch,
                  onUnitSelected: (u) => setState(() => _selectedBoughtUnit = u),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerUnitInnerRow({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.neutralText)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildRateInput(TextEditingController controller, String hint, {String? prefix, bool isMono = false, double fontSize = 14}) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        children: [
          if (prefix != null) Text(prefix, style: GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: FontWeight.w700)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: isMono 
                ? GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: FontWeight.w700)
                : GoogleFonts.dmSans(fontSize: fontSize, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitMismatchWarning() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_selectedBaseUnit and $_selectedBoughtUnit are different families.',
              style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInput() {
    return Row(
      children: [
        Expanded(child: _buildRateInput(_discountController, '0', isMono: true)),
        const SizedBox(width: 12),
        _buildToggleButtons(_itemDiscountType, (val) => setState(() => _itemDiscountType = val)),
      ],
    );
  }

  Widget _buildToggleButtons(DiscountType selected, Function(DiscountType) onSelected) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildSmallToggleButton('%', selected == DiscountType.percentage, () => onSelected(DiscountType.percentage)),
          _buildSmallToggleButton('₹', selected == DiscountType.flat, () => onSelected(DiscountType.flat)),
        ],
      ),
    );
  }

  Widget _buildSmallToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.neutralText, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildItemTotalCard(CartItem item) {
    String formula = '';
    if (item.priceMode == PriceMode.flatRate) {
      formula = "${item.quantity} × Flat Rate";
    } else {
      formula = "(${item.boughtQty}${item.boughtUnit} ÷ ${item.baseQty}${item.baseUnit}) × ₹${item.enteredAmount}";
    }

    if (item.discountValue > 0) {
      String discStr = item.discountType == DiscountType.percentage ? "${item.discountValue.toStringAsFixed(0)}%" : "₹${item.discountValue.toStringAsFixed(0)}";
      formula += " - $discStr off";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2D5A27), Color(0xFF1E3A1A)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ITEM TOTAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                FittedBox(
                   fit: BoxFit.scaleDown,
                   child: Text(formula, style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 10)),
                ),
              ],
            ),
          ),
          Text('₹${item.itemFinalPrice.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(color: AppColors.primaryGreen, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildVendorDiscountRow() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFEFCE8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE047), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Text('🤝 Vendor Off', style: GoogleFonts.dmSans(color: const Color(0xFF854D0E), fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: _buildRateInput(_vendorDiscountController, '0', isMono: true, fontSize: 13)),
          const SizedBox(width: 8),
          _buildToggleButtons(_vendorDiscountType, (val) => setState(() => _vendorDiscountType = val)),
        ],
      ),
    );
  }

  Widget _buildFinalTotalCard(CartItem item) {
    String formula = "₹${item.itemFinalPrice.toStringAsFixed(0)}";
    if (item.vendorDiscountValue > 0) {
      String discStr = item.vendorDiscountType == DiscountType.percentage ? "${item.vendorDiscountValue.toStringAsFixed(0)}%" : "₹${item.vendorDiscountValue.toStringAsFixed(0)}";
      formula += " - $discStr Vendor Off";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF92400E), Color(0xFF78350F)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FINAL ITEM TOTAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(formula, style: GoogleFonts.jetBrainsMono(color: Colors.white70, fontSize: 10)),
              ],
            ),
          ),
          Text('₹${item.itemAfterVendorDiscount.toStringAsFixed(0)}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFFFDE047), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    bool disabled = !_isValid;
    return SizedBox(
      width: double.infinity,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.3 : 1.0,
        child: ElevatedButton(
          onPressed: disabled ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            disabledBackgroundColor: Colors.grey[400],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(widget.editItem != null ? 'Update Item' : '＋ Add Item', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
