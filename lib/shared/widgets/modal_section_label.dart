import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class ModalSectionLabel extends StatelessWidget {
  final String label;

  const ModalSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingXS),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: AppDimensions.fontS - 1,
          fontWeight: FontWeight.w900,
          color: AppColors.neutralText,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
