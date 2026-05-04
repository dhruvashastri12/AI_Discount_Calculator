// test/widget/features/shopping_list/widgets/item_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/item_card.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('ItemCard Widget Tests', () {
    late CartItem testItem;

    setUp(() {
      testItem = CartItem(
        id: '1',
        itemName: 'Test Item',
        quantity: '1 Unit',
        unitType: 'Unit',
        priceMode: PriceMode.flatRate,
        enteredAmount: 100.0,
        baseQty: 1.0,
        baseUnit: 'Unit',
        boughtQty: 1.0,
        boughtUnit: 'Unit',
        discountValue: 0.0, // No discount to keep calculations simple
        discountType: DiscountType.percentage,
        categoryId: 'grocery',
        date: DateTime.now(),
        vendorDiscountValue: 0,
        vendorDiscountType: DiscountType.flat,
        iconCode: 0,
      );
    });

    testWidgets('ItemCard should render name, quantity and prices', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          ItemCard(
            item: testItem,
            isExpanded: false,
            onToggle: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('1 Unit'), findsOneWidget);
      // PriceDisplay should show 100 (final price)
      expect(find.textContaining('100'), findsAtLeastNWidgets(1));
    });

    testWidgets('ItemCard should show detail panel when expanded', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        wrapWithMaterialApp(
          Material(
            child: SingleChildScrollView(
              child: ItemCard(
                item: testItem,
                isExpanded: true,
                onToggle: () {},
                onEdit: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      // Verify detail labels
      expect(find.text('Original Price'), findsOneWidget);
      expect(find.text('Paid Amount'), findsOneWidget);
      
      // With no discount, all prices should be 100
      expect(find.textContaining('100'), findsAtLeastNWidgets(2));

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
