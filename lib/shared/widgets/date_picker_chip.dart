import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';

class DatePickerChip extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerChip({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    bool isToday = selectedDate.isAtSameMomentAs(today);
    String dateStr = isToday
        ? AppStrings.modalToday
        : DateFormat(AppStrings.formatShortDate).format(selectedDate).toUpperCase();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
            vertical: AppDimensions.paddingM,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.neutralChip,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              Text(
                "$dateStr (${AppStrings.modalTapToChange})",
                style: TextStyle(fontFamily: 'DMSans', 
                  fontSize: AppDimensions.fontS + 1,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
