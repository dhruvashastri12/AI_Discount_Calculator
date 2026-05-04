// test/widget/shared/widgets/summary_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/shared/widgets/summary_card.dart';

void main() {
  testWidgets('SummaryCard should render its children correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            children: [
              Text('Child 1'),
              Text('Child 2'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Child 1'), findsOneWidget);
    expect(find.text('Child 2'), findsOneWidget);
    
    // Verify it's a Column inside the card
    expect(find.byType(Column), findsOneWidget);
  });
}
