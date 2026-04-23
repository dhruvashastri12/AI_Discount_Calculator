import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

/// Central manager to ensure only one dropdown is open at a time.
class DropdownManager {
  static OverlayEntry? _currentEntry;
  static VoidCallback? _onDismiss;

  static bool get isAnyOpen => _currentEntry != null;

  static void show(BuildContext context, OverlayEntry entry, {VoidCallback? onDismiss}) {
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
  final LayerLink _moreLink = LayerLink();
  bool _isMoreOpen = false;

  final List<Map<String, String>> _quickCats = [
    {'name': 'DAIRY', 'emoji': '🥛'},
    {'name': 'VEGGIES & FRUITS', 'emoji': '🥦'},
    {'name': 'GROCERY', 'emoji': '🛒'},
    {'name': 'HOUSEHOLD', 'emoji': '🏠'},
  ];

  final List<Map<String, String>> _moreOptions = [
    {'name': 'Clothing', 'emoji': '👗'},
    {'name': 'Stationery', 'emoji': '✏️'},
    {'name': 'Electronics', 'emoji': '📱'},
    {'name': 'Health', 'emoji': '💊'},
    {'name': 'Beauty', 'emoji': '💄'},
  ];

  String _getEmoji(String name) {
    for (var cat in _quickCats) {
      if (cat['name'] == name) return cat['emoji']!;
    }
    for (var cat in _moreOptions) {
      if (cat['name'] == name) return cat['emoji']!;
    }
    return '🏷️';
  }

  void _toggleMore() {
    if (_isMoreOpen) {
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
              link: _moreLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ..._moreOptions.map((opt) => _buildMoreRow(opt['name']!, opt['emoji']!)),
                      const SizedBox(height: 6),
                      const Divider(height: 1, color: AppColors.borderDefault),
                      const SizedBox(height: 6),
                      _buildCustomInputRow(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      DropdownManager.show(context, entry, onDismiss: () {
        if (mounted) setState(() => _isMoreOpen = false);
      });
      setState(() => _isMoreOpen = true);
    }
  }

  Widget _buildMoreRow(String name, String emoji) {
    bool isSelected = widget.selectedCategory == name;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: () {
        widget.onCategorySelected(name, emoji);
        DropdownManager.dismiss();
      },
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 11),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInputRow() {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 11),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const Text('✏️', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : AppColors.textDark),
              decoration: InputDecoration(
                hintText: 'Type custom name...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.neutralText.withValues(alpha: 0.6), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  widget.onCategorySelected(val.trim().toUpperCase(), '🏷️');
                  DropdownManager.dismiss();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isQuickSelected = _quickCats.any((cat) => cat['name'] == widget.selectedCategory);
    bool isMoreSelected = !isQuickSelected && widget.selectedCategory.isNotEmpty;

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          ..._quickCats.map((cat) => _buildChip(
                name: cat['name']!,
                emoji: cat['emoji']!,
                isSelected: widget.selectedCategory == cat['name'],
                onTap: () => widget.onCategorySelected(cat['name']!, cat['emoji']!),
              )),
          CompositedTransformTarget(
            link: _moreLink,
            child: _buildMoreChip(
              isSelected: isMoreSelected,
              isOpen: _isMoreOpen,
              onTap: _toggleMore,
            ),
          ),
        ],
      ),
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
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenTint : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip),
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
              name.split(' ').first,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
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

  Widget _buildMoreChip({
    required bool isSelected,
    required bool isOpen,
    required VoidCallback onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String label = isSelected ? widget.selectedCategory.toUpperCase() : 'MORE';
    String topIcon = isSelected ? _getEmoji(widget.selectedCategory) : '···';

    Color contentColor = (isSelected || isOpen) ? AppColors.darkGreen : AppColors.neutralText;
    Color bgColor = (isSelected || isOpen) ? AppColors.greenTint : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip);
    Color borderColor = (isSelected || isOpen) ? AppColors.darkGreen : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topIcon,
              style: TextStyle(
                fontSize: isSelected ? 22 : 20,
                fontWeight: FontWeight.w700,
                color: contentColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: contentColor,
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
    'pcs', 'g', 'kg', 'ml', 'ltr', 'tin', 'dzn', 'pair', 'pkt', 'mtr', 'ft', 'cm', 'galn'
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
                    border: Border.all(color: AppColors.borderDefault, width: 0.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 28,
                        offset: Offset(0, 8),
                      )
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
                        widget.isGreen
                            ? "Vendor's unit"
                            : "Your unit",
                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.neutralText),
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

      DropdownManager.show(context, entry, onDismiss: () {
        if (mounted) setState(() => _isOpen = false);
      });
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
    
    Color bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip;
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
          style: GoogleFonts.jetBrainsMono(
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
    Color borderColor = widget.isGreen ? AppColors.darkGreen : AppColors.blueBorder;
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
                style: GoogleFonts.jetBrainsMono(
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
