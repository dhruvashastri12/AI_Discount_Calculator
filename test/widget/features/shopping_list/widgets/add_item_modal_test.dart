// test/widget/features/shopping_list/widgets/add_item_modal_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/add_item_modal.dart';
import 'package:ai_discount_calculator/core/constants/app_strings.dart';
import '../../../../helpers/test_helpers.dart'; // Corrected path (4 levels up)

void main() {
  group('AddItemModal Widget Tests', () {
    testWidgets('AddItemModal should show preview calculations as inputs change', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          AddItemModal(
            onItemAdded: (item) {},
          ),
        ),
      );

      // Verify initial state
      expect(find.text(AppStrings.modalAddItem), findsOneWidget);

      // 1. Enter Price (TextField index 2 for flat rate amount)
      final priceField = find.byType(TextField).at(2);
      await tester.enterText(priceField, '100');
      await tester.pump();

      // 2. Enter Discount (TextField index 3)
      final discountField = find.byType(TextField).at(3);
      await tester.enterText(discountField, '10');
      await tester.pump();

      // Check preview section
      // In flat rate, subtotal = 100. 10% discount = 10. Final = 90.
      // The UI uses toStringAsFixed(0) for major total cards
      expect(find.textContaining('100'), findsAtLeastNWidgets(1));
      expect(find.textContaining('90'), findsOneWidget);
    });
  });
}
