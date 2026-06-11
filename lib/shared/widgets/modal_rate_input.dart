import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class ModalRateInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefix;
  final bool isMono;
  final double fontSize;
  final Function(String)? onChanged;

  const ModalRateInput({
    super.key,
    required this.controller,
    required this.hint,
    this.prefix,
    this.isMono = true,
    this.fontSize = 14,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    print(
      "ModalRateInput: build called, padding vertical = ${AppDimensions.paddingM}",
    );
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS + 1),
        border: Border.all(color: AppColors.borderDefault, width: 0.5),
      ),
      child: Row(
        children: [
          if (prefix != null)
            Text(
              prefix!,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: isMono
                  ? TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                    )
                  : TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.all(5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
