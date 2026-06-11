import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/cart_item.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/custom_dropdowns.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/modal_components.dart';
import '../../../../shared/widgets/modal_section_label.dart';
import '../../../../shared/widgets/total_card.dart';
import '../../../../shared/widgets/modal_rate_input.dart';
import '../../../../shared/widgets/discount_type_toggle.dart';
import '../../../../shared/widgets/date_picker_chip.dart';

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
  final TextEditingController _flatQtyController = TextEditingController(
    text: '1',
  );

  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _baseQtyController = TextEditingController(
    text: '1',
  );
  final TextEditingController _boughtQtyController = TextEditingController();

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _vendorDiscountController =
      TextEditingController();

  PriceMode _priceMode = PriceMode.flatRate;
  String _selectedCategory = '';
  String _selectedBaseUnit = 'kg';
  String _selectedBoughtUnit = 'g';
  DiscountType _itemDiscountType = DiscountType.percentage;
  DiscountType _vendorDiscountType = DiscountType.flat;
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
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
        _flatAmountController.text = it.enteredAmount.toString().replaceAll(
          RegExp(r'\.0$'),
          '',
        );
        _flatQtyController.text = it.boughtQty.toString().replaceAll(
          RegExp(r'\.0$'),
          '',
        );
        _selectedBoughtUnit = it.boughtUnit;
      } else {
        _basePriceController.text = it.enteredAmount.toString().replaceAll(
          RegExp(r'\.0$'),
          '',
        );
        _baseQtyController.text = it.baseQty.toString().replaceAll(
          RegExp(r'\.0$'),
          '',
        );
        _selectedBaseUnit = it.baseUnit;
        _boughtQtyController.text = it.boughtQty.toString().replaceAll(
          RegExp(r'\.0$'),
          '',
        );
        _selectedBoughtUnit = it.boughtUnit;
      }
      _discountController.text = it.discountValue > 0
          ? it.discountValue.toString().replaceAll(RegExp(r'\.0$'), '')
          : '';
      _itemDiscountType = it.discountType;
      _vendorDiscountController.text = it.vendorDiscountValue > 0
          ? it.vendorDiscountValue.toString().replaceAll(RegExp(r'\.0$'), '')
          : '';
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
    return _getUnitFamily(_selectedBaseUnit) !=
        _getUnitFamily(_selectedBoughtUnit);
  }

  bool get _isValid {
    if (_selectedCategory.isEmpty) return false;
    if (_nameController.text.trim().isEmpty) return false;
    if (_isUnitMismatch) return false;

    if (_priceMode == PriceMode.flatRate) {
      return _flatAmountController.text.isNotEmpty &&
          _flatQtyController.text.isNotEmpty;
    } else {
      return _basePriceController.text.isNotEmpty &&
          _baseQtyController.text.isNotEmpty &&
          _boughtQtyController.text.isNotEmpty;
    }
  }

  CartItem _calculateTempItem() {
    double enteredAmount =
        double.tryParse(
          _priceMode == PriceMode.flatRate
              ? _flatAmountController.text
              : _basePriceController.text,
        ) ??
        0;
    double baseQty =
        double.tryParse(
          _priceMode == PriceMode.flatRate
              ? _flatQtyController.text
              : _baseQtyController.text,
        ) ??
        1;
    double boughtQty =
        double.tryParse(
          _priceMode == PriceMode.flatRate
              ? _flatQtyController.text
              : _boughtQtyController.text,
        ) ??
        1;

    return CartItem(
      id:
          widget.editItem?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      itemName: _nameController.text,
      quantity:
          "${boughtQty.toString().replaceAll(RegExp(r'\.0$'), '')}$_selectedBoughtUnit",
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
      bottom: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.paddingM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Text(
              widget.editItem != null
                  ? AppStrings.modalEditItem
                  : AppStrings.modalAddItem,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: AppDimensions.fontTitleS,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingXL,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DatePickerChip(
                      selectedDate: _selectedDate,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    const ModalSectionLabel(label: AppStrings.modalItemName),
                    _buildTextInput(
                      _nameController,
                      AppStrings.modalEnterItemName,
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    const ModalSectionLabel(label: AppStrings.modalCategory),
                    CategorySelector(
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (name, emoji) =>
                          setState(() => _selectedCategory = name),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    const ModalSectionLabel(label: AppStrings.modalMarket),
                    MarketSelector(
                      marketType: _marketType,
                      onMarketChanged: (type) =>
                          setState(() => _marketType = type),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    const ModalSectionLabel(label: AppStrings.modalPriceMode),
                    PriceModeToggle(
                      priceMode: _priceMode,
                      onModeChanged: (mode) =>
                          setState(() => _priceMode = mode),
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    if (_priceMode == PriceMode.flatRate)
                      _buildFlatRateFields()
                    else
                      _buildPerUnitFields(),

                    if (_isUnitMismatch) _buildUnitMismatchWarning(),
                    const SizedBox(height: AppDimensions.paddingXL),

                    const ModalSectionLabel(
                      label: AppStrings.modalItemDiscount,
                    ),
                    _buildDiscountInput(),
                    const SizedBox(height: AppDimensions.paddingXL),

                    _buildItemTotalCard(tempItem),
                    const SizedBox(height: AppDimensions.paddingM),

                    _buildVendorDiscountRow(),
                    if (tempItem.vendorDiscountValue > 0) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.paddingS,
                          ),
                          child: Text(
                            AppStrings.modalAfterVendorDiscount,
                            style: TextStyle(
                              fontSize: AppDimensions.fontXS,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      _buildFinalTotalCard(tempItem),
                    ],

                    const SizedBox(height: AppDimensions.paddingXXL),
                    _buildAddButton(),
                    const SizedBox(height: AppDimensions.paddingXXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        border: Border.all(color: AppColors.primaryGreen, width: 1),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'DMSans',
          color: AppColors.navBarDark,
          fontSize: AppDimensions.fontTitleS,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'DMSans',
            color: AppColors.neutralText.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingM,
            horizontal: AppDimensions.paddingS,
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
            Expanded(
              child: ModalRateInput(
                controller: _flatQtyController,
                hint: AppStrings.listQty,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: ModalRateInput(
                controller: _flatAmountController,
                hint: AppStrings.historyTotal,
                prefix: '₹ ',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingM),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'pcs',
            'g',
            'kg',
            'ml',
            'ltr',
            'tin',
            'dzn',
            'pair',
            'pkt',
            'mtr',
            'ft',
            'cm',
            'galn',
          ].map((u) => _buildSmallUnitChip(u)).toList(),
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blueTint
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.neutralChip),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.blueBorder : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          u,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: AppDimensions.fontS,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.blueText : AppColors.neutralText,
          ),
        ),
      ),
    );
  }

  Widget _buildPerUnitFields() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM + 1),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Column(
        children: [
          _buildPerUnitInnerRow(
            label: AppStrings.modalVendorRate,
            child: Row(
              children: [
                Text(
                  '₹',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutralText,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ModalRateInput(
                    controller: _basePriceController,
                    hint: '0',
                    fontSize: 15,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.modalPer,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: AppColors.neutralText,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 38,
                  child: ModalRateInput(
                    controller: _baseQtyController,
                    hint: '1',
                    fontSize: 13,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
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
            padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
            child: Divider(height: 1, color: AppColors.borderDefault),
          ),
          _buildPerUnitInnerRow(
            label: AppStrings.modalYouBought,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ModalRateInput(
                    controller: _boughtQtyController,
                    hint: '0',
                    fontSize: 13,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                UnitPickerPill(
                  unit: _selectedBoughtUnit,
                  isGreen: false,
                  isError: _isUnitMismatch,
                  onUnitSelected: (u) =>
                      setState(() => _selectedBoughtUnit = u),
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
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DMSans',
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.neutralText,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildUnitMismatchWarning() {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.paddingM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBG,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_selectedBaseUnit and $_selectedBoughtUnit are different families.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: AppDimensions.fontXS,
                fontWeight: FontWeight.w600,
                color: AppColors.warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountInput() {
    return Row(
      children: [
        Expanded(
          child: ModalRateInput(
            controller: _discountController,
            hint: '0',
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        DiscountTypeToggle(
          selected: _itemDiscountType,
          onSelected: (val) => setState(() => _itemDiscountType = val),
        ),
      ],
    );
  }

  Widget _buildItemTotalCard(CartItem item) {
    String formula = '';
    if (item.priceMode == PriceMode.flatRate) {
      formula = "${item.quantity} × Flat Rate";
    } else {
      formula =
          "(${item.boughtQty}${item.boughtUnit} ÷ ${item.baseQty}${item.baseUnit}) × ₹${item.enteredAmount}";
    }

    if (item.discountValue > 0) {
      String discStr = item.discountType == DiscountType.percentage
          ? "${item.discountValue.toStringAsFixed(0)}%"
          : "₹${item.discountValue.toStringAsFixed(0)}";
      formula += " - $discStr off";
    }

    return TotalCard(
      title: AppStrings.modalItemTotal,
      formula: formula,
      amount: item.itemFinalPrice,
      gradientColors: const [
        AppColors.gradientItemTotalStart,
        AppColors.gradientItemTotalEnd,
      ],
      amountColor: AppColors.primaryGreen,
    );
  }

  Widget _buildVendorDiscountRow() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
          Text(
            AppStrings.modalVendorOff,
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
              controller: _vendorDiscountController,
              hint: '0',
              fontSize: 13,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          DiscountTypeToggle(
            selected: _vendorDiscountType,
            onSelected: (val) => setState(() => _vendorDiscountType = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTotalCard(CartItem item) {
    String formula = "₹${item.itemFinalPrice.toStringAsFixed(0)}";
    if (item.vendorDiscountValue > 0) {
      String discStr = item.vendorDiscountType == DiscountType.percentage
          ? "${item.vendorDiscountValue.toStringAsFixed(0)}%"
          : "₹${item.vendorDiscountValue.toStringAsFixed(0)}";
      formula += " - $discStr Vendor Off";
    }

    return TotalCard(
      title: AppStrings.modalFinalItemTotal,
      formula: formula,
      amount: item.itemAfterVendorDiscount,
      gradientColors: const [
        AppColors.gradientFinalTotalStart,
        AppColors.gradientFinalTotalEnd,
      ],
      amountColor: AppColors.finalTotalValue,
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
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingL,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            elevation: 0,
          ),
          child: Text(
            widget.editItem != null
                ? AppStrings.modalBtnUpdate
                : AppStrings.modalBtnAdd,
            style: TextStyle(
              fontFamily: 'DMSans',
              color: Colors.white,
              fontSize: AppDimensions.fontM + 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
