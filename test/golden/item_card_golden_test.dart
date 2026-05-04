// test/golden/item_card_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/features/shopping_list/presentation/widgets/item_card.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';
import '../helpers/test_helpers.dart';

void main() {
  testWidgets('ItemCard Golden Test', (WidgetTester tester) async {
    final mockItem = CartItem(
      id: '1',
      itemName: 'Organic Milk',
      quantity: '2 Litre',
      unitType: 'Volume',
      priceMode: PriceMode.flatRate,
      enteredAmount: 120.0,
      baseQty: 1.0,
      baseUnit: 'Litre',
      boughtQty: 2.0,
      boughtUnit: 'Litre',
      discountValue: 10.0,
      discountType: DiscountType.percentage,
      categoryId: 'dairy',
      date: DateTime(2024, 1, 1),
      vendorDiscountValue: 5.0,
      vendorDiscountType: DiscountType.flat,
      iconCode: 0,
    );

    const targetKey = Key('item_card_list_target');

    await tester.pumpWidget(
      wrapWithMaterialApp(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: RepaintBoundary(
            key: targetKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ItemCard(
                  item: mockItem,
                  isExpanded: false,
                  onToggle: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
                const SizedBox(height: 20),
                ItemCard(
                  item: mockItem,
                  isExpanded: true,
                  onToggle: () {},
                  onEdit: () {},
                  onDelete: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(targetKey),
      matchesGoldenFile('goldens/item_card_states.png'),
    );
  });
}
