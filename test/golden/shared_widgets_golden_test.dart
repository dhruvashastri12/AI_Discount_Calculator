// test/golden/shared_widgets_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/shared/widgets/badge_chip.dart';
import 'package:ai_discount_calculator/shared/widgets/savings_strip.dart';
import 'package:ai_discount_calculator/shared/widgets/category_header.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Shared Widgets Golden Tests', () {
    testWidgets('BadgeChip Golden Test', (WidgetTester tester) async {
      const targetKey = Key('badge_chip_target');
      await tester.pumpWidget(
        wrapWithMaterialApp(
          Center(
            child: RepaintBoundary(
              key: targetKey,
              child: const BadgeChip(label: 'Saved ₹50'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(targetKey),
        matchesGoldenFile('goldens/badge_chip.png'),
      );
    });

    testWidgets('SavingsStrip Golden Test', (WidgetTester tester) async {
      const targetKey = Key('savings_strip_target');
      await tester.pumpWidget(
        wrapWithMaterialApp(
          Center(
            child: RepaintBoundary(
              key: targetKey,
              child: const SavingsStrip(amount: 150.0, percentage: 15),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(targetKey),
        matchesGoldenFile('goldens/savings_strip.png'),
      );
    });

    testWidgets('CategoryHeader Golden Test', (WidgetTester tester) async {
      const targetKey = Key('category_header_target');
      await tester.pumpWidget(
        wrapWithMaterialApp(
          Center(
            child: RepaintBoundary(
              key: targetKey,
              child: const CategoryHeader(
                emoji: '🛒',
                title: 'GROCERY',
                itemCount: 5,
                subtotal: 450.0,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(targetKey),
        matchesGoldenFile('goldens/category_header.png'),
      );
    });
  });
}
