import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';

class TotalCard extends StatelessWidget {
  final String title;
  final String formula;
  final double amount;
  final List<Color> gradientColors;
  final Color amountColor;

  const TotalCard({
    super.key,
    required this.title,
    required this.formula,
    required this.amount,
    required this.gradientColors,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXS),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formula,
                    style: TextStyle(fontFamily: 'JetBrainsMono', 
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontFamily: 'JetBrainsMono', 
              color: amountColor,
              fontSize: AppDimensions.fontDisplayS,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
