// test/widget/shared/widgets/basic_shared_widgets_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/shared/widgets/badge_chip.dart';
import 'package:ai_discount_calculator/shared/widgets/category_header.dart';
import 'package:ai_discount_calculator/shared/widgets/savings_strip.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import '../../../helpers/test_helpers.dart'; // Corrected path (3 levels up)

void main() {
  group('Basic Shared Widgets Tests', () {
    testWidgets('BadgeChip should render label', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const BadgeChip(label: 'OFF 20%')),
      );

      expect(find.text('OFF 20%'), findsOneWidget);
    });

    testWidgets('CategoryHeader should render uppercase title and item count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const CategoryHeader(
            emoji: '🍎',
            title: 'Fruits',
            itemCount: 3,
            subtotal: 100.0,
          ),
        ),
      );

      // CategoryHeader uses .toUpperCase() on title
      expect(find.text('FRUITS'), findsOneWidget);
      expect(find.text('🍎'), findsOneWidget);
      // It renders "3 items" (lowercase i)
      expect(find.textContaining('3 items'), findsOneWidget);
    });

    testWidgets('SavingsStrip should render savings summary', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const SavingsStrip(amount: 50.0, percentage: 10)),
      );

      // SavingsStrip renders amount and percentage in separate widgets
      // label part: "Saved ₹ today 50" (amount.toStringAsFixed(0))
      expect(find.textContaining(AppStrings.listSavedToday), findsOneWidget);
      expect(find.textContaining('50'), findsAtLeastNWidgets(1));

      // percentage part: "10%"
      expect(find.text('10%'), findsOneWidget);
    });
  });
}
