import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class SummaryCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const SummaryCard({
    super.key,
    required this.children,
    this.margin,
    this.padding = const EdgeInsets.all(AppDimensions.paddingL),
    this.color,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.cardDark : AppColors.white),
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        boxShadow: boxShadow ?? (isDark ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
