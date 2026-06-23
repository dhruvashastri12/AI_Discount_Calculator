import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';

/// Central manager to ensure only one dropdown is open at a time.
class DropdownManager {
  static OverlayEntry? _currentEntry;
  static VoidCallback? _onDismiss;

  static bool get isAnyOpen => _currentEntry != null;

  static void show(
    BuildContext context,
    OverlayEntry entry, {
    VoidCallback? onDismiss,
  }) {
    dismiss();
    FocusManager.instance.primaryFocus?.unfocus(); // Close keyboard
    _currentEntry = entry;
    _onDismiss = onDismiss;
    Overlay.of(context).insert(_currentEntry!);
  }

  static void dismiss() {
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
      _onDismiss?.call();
      _onDismiss = null;
    }
  }
}

class CategorySelector extends StatefulWidget {
  final String selectedCategory;
  final Function(String name, String emoji) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  static const Set<String> _predefinedNames = {
    'DAIRY',
    'VEGGIES',
    'GROCERY',
    'HEALTH',
    'STATIONARY',
    'STATIONERY',
    'ELECTRONICS',
    'CLOTHING',
    'BEAUTY',
  };

  void _showCustomCategoryDialog() {
    String selectedUpper = widget.selectedCategory.toUpperCase();
    bool isCustomSelected =
        widget.selectedCategory.isNotEmpty &&
        !_predefinedNames.contains(selectedUpper);

    final TextEditingController dialogController = TextEditingController(
      text: isCustomSelected ? widget.selectedCategory : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        bool isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Custom Category',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? Colors.white : AppColors.navBarDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter category name (max 10 chars)',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  color: AppColors.neutralText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.neutralChip,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryGreen, width: 1),
                ),
                // padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: dialogController,
                  autofocus: true,
                  maxLength: 10,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.navBarDark,
                  ),
                  decoration: const InputDecoration(
                    counterText: '', // Hide default counter text
                    hintText: 'e.g. Pets, Gifts...',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: isDark ? Colors.white60 : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final text = dialogController.text.trim();
                if (text.isNotEmpty) {
                  widget.onCategorySelected(text.toUpperCase(), '🏷️');
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedUpper = widget.selectedCategory.toUpperCase();
    bool isCustomSelected =
        widget.selectedCategory.isNotEmpty &&
        !_predefinedNames.contains(selectedUpper);

    final List<Map<String, String>> row1Cats = [
      {'name': 'DAIRY', 'emoji': '🥛'},
      {'name': 'VEGGIES', 'emoji': '🥦'},
      {'name': 'GROCERY', 'emoji': '🛒'},
      {'name': 'HEALTH', 'emoji': '💊'},
      {'name': 'STATIONARY', 'emoji': '✏️'},
    ];

    final List<Map<String, String>> row2Cats = [
      {'name': 'ELECTRONICS', 'emoji': '📱'},
      {'name': 'CLOTHING', 'emoji': '👗'},
      {'name': 'BEAUTY', 'emoji': '💄'},
    ];

    List<Widget> row1Widgets = [];
    for (int i = 0; i < row1Cats.length; i++) {
      var cat = row1Cats[i];
      String name = cat['name']!;
      String emoji = cat['emoji']!;
      bool isSelected = selectedUpper == name;
      row1Widgets.add(
        Expanded(
          child: _buildChip(
            name: name,
            emoji: emoji,
            isSelected: isSelected,
            onTap: () => widget.onCategorySelected(name, emoji),
          ),
        ),
      );
      if (i < row1Cats.length - 1) {
        row1Widgets.add(const SizedBox(width: 8));
      }
    }

    List<Widget> row2Widgets = [];
    for (int i = 0; i < row2Cats.length; i++) {
      var cat = row2Cats[i];
      String name = cat['name']!;
      String emoji = cat['emoji']!;
      bool isSelected = selectedUpper == name;
      row2Widgets.add(
        Expanded(
          child: _buildChip(
            name: name,
            emoji: emoji,
            isSelected: isSelected,
            onTap: () => widget.onCategorySelected(name, emoji),
          ),
        ),
      );
      row2Widgets.add(const SizedBox(width: 8));
    }

    row2Widgets.add(
      Expanded(
        child: _buildCustomChip(
          isSelected: isCustomSelected,
          customValue: isCustomSelected ? widget.selectedCategory : 'Custom',
          onTap: _showCustomCategoryDialog,
        ),
      ),
    );

    row2Widgets.add(const SizedBox(width: 8));
    row2Widgets.add(const Expanded(child: SizedBox()));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: row1Widgets),
        const SizedBox(height: 8),
        Row(children: row2Widgets),
      ],
    );
  }

  Widget _buildChip({
    required String name,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.greenTint
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.neutralChip),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: isSelected ? AppColors.darkGreen : AppColors.neutralText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomChip({
    required bool isSelected,
    required String customValue,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String displayLabel = customValue.toUpperCase();
    String emoji = isSelected ? '🏷️' : '✏️';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.greenTint
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.neutralChip),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkGreen : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              child: Text(
                displayLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: isSelected
                      ? AppColors.darkGreen
                      : AppColors.neutralText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnitPickerPill extends StatefulWidget {
  final String unit;
  final bool isGreen;
  final bool isError;
  final Function(String) onUnitSelected;

  const UnitPickerPill({
    super.key,
    required this.unit,
    required this.onUnitSelected,
    this.isGreen = true,
    this.isError = false,
  });

  @override
  State<UnitPickerPill> createState() => _UnitPickerPillState();
}

class _UnitPickerPillState extends State<UnitPickerPill> {
  final LayerLink _link = LayerLink();
  bool _isOpen = false;

  final List<String> _units = [
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
  ];

  void _togglePopup() {
    if (_isOpen) {
      DropdownManager.dismiss();
    } else {
      final entry = OverlayEntry(
        builder: (context) => Stack(
          children: [
            GestureDetector(
              onTap: DropdownManager.dismiss,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.borderDefault,
                      width: 0.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildUnitGrid(),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: AppColors.borderDefault),
                      const SizedBox(height: 6),
                      Text(
                        widget.isGreen ? "Vendor's unit" : "Your unit",
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 10,
                          color: AppColors.neutralText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      DropdownManager.show(
        context,
        entry,
        onDismiss: () {
          if (mounted) setState(() => _isOpen = false);
        },
      );
      setState(() => _isOpen = true);
    }
  }

  Widget _buildUnitGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: _units.map((u) => _buildUnitOption(u)).toList(),
    );
  }

  Widget _buildUnitOption(String u) {
    bool isSelected = widget.unit == u;
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.neutralChip;
    Color borderColor = Colors.transparent;
    Color textColor = AppColors.neutralText;

    if (isSelected) {
      if (widget.isGreen) {
        bgColor = AppColors.greenTint;
        borderColor = AppColors.darkGreen;
        textColor = AppColors.darkGreen;
      } else {
        bgColor = AppColors.blueTint;
        borderColor = AppColors.blueBorder;
        textColor = AppColors.blueText;
      }
    }

    return GestureDetector(
      onTap: () {
        widget.onUnitSelected(u);
        DropdownManager.dismiss();
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Text(
          u,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.isGreen ? AppColors.greenTint : AppColors.blueTint;
    Color borderColor = widget.isGreen
        ? AppColors.darkGreen
        : AppColors.blueBorder;
    Color textColor = widget.isGreen ? AppColors.darkGreen : AppColors.blueText;

    if (widget.isError) {
      bgColor = AppColors.errorTint;
      borderColor = AppColors.errorBorder;
      textColor = AppColors.errorText;
    }

    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _togglePopup,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.unit,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Opacity(
                opacity: 0.65,
                child: Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
