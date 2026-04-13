import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_discount_calculator/core/constants/app_colors.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import 'package:ai_discount_calculator/core/constants/app_constants.dart';

/// Screen for calculating discounts with an interactive keypad.
/// Supports both percentage and flat currency discounts.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // Input state variables
  String originalPriceStr = "0";
  String discountStr = "0";
  bool isPercent = true;
  bool selectingPrice = true;
  String? limitWarning;

  // Calculators converting string inputs to numeric values
  double get originalPrice => double.tryParse(originalPriceStr) ?? 0.0;
  double get discountValue => double.tryParse(discountStr) ?? 0.0;

  /// Calculates the total currency amount saved based on current inputs.
  double get savedAmount {
    if (isPercent) {
      return (originalPrice * discountValue) / 100;
    } else {
      return discountValue;
    }
  }

  /// Calculates the final amount to be paid.
  double get payableAmount {
    return (originalPrice - savedAmount).clamp(0, double.infinity);
  }

  /// Handles custom keypad interactions including number entry, backspace, and clearing.
  void _onKeyTap(String key) {
    setState(() {
      limitWarning = null;
      if (key == "AC") {
        originalPriceStr = "0";
        discountStr = "0";
        selectingPrice = true;
      } else if (key == "backspace") {
        String current = selectingPrice ? originalPriceStr : discountStr;
        if (current.length > 1) {
          current = current.substring(0, current.length - 1);
        } else {
          current = "0";
        }
        if (selectingPrice) {
          originalPriceStr = current;
        } else {
          discountStr = current;
        }
      } else {
        String current = selectingPrice ? originalPriceStr : discountStr;

        // Prevent overflow beyond max allowed digits
        if (current.replaceAll(".", "").length >= AppConstants.maxInputDigits) {
          limitWarning = "Maximum ${AppConstants.maxInputDigits} digits allowed";
          return;
        }

        if (current == "0") {
          current = key;
        } else {
          current += key;
        }
        
        // Update the active input field
        if (selectingPrice) {
          originalPriceStr = current;
        } else {
          discountStr = current;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color currentBg = isDark ? AppColors.background : AppColors.backgroundLight;
    final Color currentSurface = isDark ? AppColors.surface : AppColors.white;

    return Scaffold(
      backgroundColor: currentBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Results Section (Top Half)
            Expanded(
              flex: AppConstants.calcTopFlex.toInt(),
              child: _buildResultBoard(isDark),
            ),

            // Keypad & Input Controls (Bottom Half)
            Expanded(
              flex: AppConstants.calcBottomFlex.toInt(),
              child: _buildControlsSection(isDark, currentSurface),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the display showing the calculated payable amount.
  Widget _buildResultBoard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS + 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!isDark)
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.primaryCalc.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.calcFinalPrice,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: AppConstants.fontSizeM - 1,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: AppConstants.spaceXS + 2),
              FittedBox(
                 fit: BoxFit.scaleDown,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceL),
                   child: Text(
                     "${AppStrings.calcRupeeSymbol}${payableAmount.toStringAsFixed(2)}",
                     style: GoogleFonts.spaceGrotesk(
                       fontSize: AppConstants.fontSizeGiant,
                       fontWeight: FontWeight.bold,
                       color: AppColors.primaryCalc,
                     ),
                   ),
                 ),
              ),
              const SizedBox(height: AppConstants.spaceS + 2),
              
              // Savings indicator pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceM + 2, 
                  vertical: AppConstants.spaceXS + 2
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surface : AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusXL),
                  border: Border.all(
                      color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.accentMuted),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: AppColors.shadow, blurRadius: 10)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "${AppStrings.calcSavings} ", 
                      style: TextStyle(fontSize: AppConstants.fontSizeS, fontWeight: FontWeight.bold, color: AppColors.textMuted)
                    ),
                    Text(
                      "${AppStrings.calcRupeeSymbol}${savedAmount.toStringAsFixed(2)}", 
                      style: TextStyle(fontSize: AppConstants.fontSizeL - 1, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.textDark)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the interactive section including input boxes and keypad.
  Widget _buildControlsSection(bool isDark, Color currentSurface) {
    return Container(
      decoration: BoxDecoration(
        color: currentSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.borderRadiusXXL + 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08), blurRadius: 25, offset: const Offset(0, -5))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(AppConstants.spaceXL, AppConstants.spaceXL, AppConstants.spaceXL, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (limitWarning != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(limitWarning!, style: const TextStyle(color: AppColors.error, fontSize: AppConstants.fontSizeS, fontWeight: FontWeight.bold)),
            ),
          
          // Original Price and Discount Input Boxes
          Row(
            children: [
              Expanded(child: _inputBox(AppStrings.calcOriginalPrice, originalPriceStr, AppStrings.calcRupeeSymbol, true, selectingPrice, isDark)),
              const SizedBox(width: AppConstants.spaceM),
              Expanded(child: _inputBox(AppStrings.calcDiscountPercent, discountStr, isPercent ? AppStrings.calcPercentSymbol : AppStrings.calcRupeeSymbol, false, !selectingPrice, isDark)),
            ],
          ),
          const SizedBox(height: AppConstants.spaceM),

          // Percentage vs Flat Toggle
          Container(
            height: AppConstants.fieldHeight - 14,
            padding: const EdgeInsets.all(AppConstants.spaceXS),
            decoration: BoxDecoration(color: isDark ? AppColors.background : AppColors.backgroundLight, borderRadius: BorderRadius.circular(AppConstants.borderRadiusM + 2)),
            child: Row(
              children: [
                _toggleButton("${AppStrings.calcPercentSymbol} Percent", isPercent, isDark, () => setState(() => isPercent = true)),
                _toggleButton("${AppStrings.calcRupeeSymbol} Flat", !isPercent, isDark, () => setState(() => isPercent = false)),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceM),

          // Custom Keypad Grid
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: AppConstants.keypadAspectRatio,
              mainAxisSpacing: AppConstants.spaceS,
              crossAxisSpacing: AppConstants.spaceS,
              children: [
                for (var i = 1; i <= 9; i++) _keyButton(i.toString(), isDark),
                _keyButton("AC", isDark, isAction: true),
                _keyButton("0", isDark),
                _keyButton("backspace", isDark, isIcon: true),
              ],
            ),
          ),
          
          // Interactivity hint
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceS),
            child: Text(
              "TAP VALUES TO EDIT",
              style: GoogleFonts.spaceGrotesk(
                fontSize: AppConstants.fontSizeS - 1, 
                color: (isDark ? AppColors.white : AppColors.textDark).withValues(alpha: 0.2),
                letterSpacing: 2.5
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a stylized input box for displaying and switching between input values.
  Widget _inputBox(String label, String value, String unit, bool unitPrefix, bool active, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() { selectingPrice = (label == AppStrings.calcOriginalPrice); limitWarning = null; }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: AppConstants.fontSizeS - 1, fontWeight: FontWeight.bold, color: active ? AppColors.primaryCalc : AppColors.textMuted)),
          const SizedBox(height: AppConstants.spaceXS + 2),
          Container(
            height: AppConstants.fieldHeight - 6,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
            decoration: BoxDecoration(
              color: isDark ? AppColors.background : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusM + 2),
              border: Border.all(color: active ? AppColors.primaryCalc : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.accentMuted), width: 1.5),
            ),
            child: Row(
              children: [
                if (unitPrefix) Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: AppConstants.fontSizeL)),
                Expanded(
                  child: Text(value, style: TextStyle(fontSize: AppConstants.fontSizeXL, fontWeight: FontWeight.bold, color: isDark ? AppColors.white : AppColors.textDark), overflow: TextOverflow.ellipsis),
                ),
                if (!unitPrefix) Text(unit, style: const TextStyle(color: AppColors.textMuted, fontSize: AppConstants.fontSizeL)),
                if (active) ...[const SizedBox(width: 4), _cursor()],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Visual cursor indicator for active input.
  Widget _cursor() {
    return Container(width: 2, height: AppConstants.fontSizeXL, color: AppColors.primaryCalc);
  }

  /// Stylized toggle switch for selecting discount type.
  Widget _toggleButton(String text, bool active, bool isDark, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: active ? AppColors.primaryCalc : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: active ? (isDark ? Colors.black : AppColors.white) : AppColors.textMuted, fontWeight: active ? FontWeight.bold : FontWeight.normal, fontSize: AppConstants.fontSizeM)),
        ),
      ),
    );
  }

  /// Reusable keypad button widget.
  Widget _keyButton(String label, bool isDark, {bool isAction = false, bool isIcon = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyTap(label),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        child: Container(
          decoration: BoxDecoration(
            color: label == "AC" ? AppColors.error.withValues(alpha: 0.08) : (isDark ? AppColors.surfaceActive : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
            border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.03) : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: isIcon 
            ? Icon(Icons.backspace_outlined, color: isDark ? AppColors.white : AppColors.textDark, size: AppConstants.iconSizeXL - 12)
            : Text(label, style: TextStyle(fontSize: isAction ? AppConstants.fontSizeL - 1 : AppConstants.fontSizeXL + 2, fontWeight: FontWeight.bold, color: label == "AC" ? AppColors.error : (isDark ? AppColors.white : AppColors.textDark))),
        ),
      ),
    );
  }
}

