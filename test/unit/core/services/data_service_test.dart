// test/unit/core/services/data_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_discount_calculator/core/services/data_service.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';

void main() {
  group('DataService Business Logic Tests', () {
    late DataService service;
    final DateTime today = DateTime(2024, 1, 1);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = DataService();
      service.clear(); // Clear singleton state before each test
    });

    CartItem createMockItem(String id, double amount, {double vendorDisc = 0.0}) {
      return CartItem(
        id: id,
        itemName: 'Item $id',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: amount,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 0.0,
        discountType: DiscountType.percentage,
        categoryId: 'grocery',
        date: today,
        vendorDiscountValue: vendorDisc,
        vendorDiscountType: DiscountType.flat,
        iconCode: 0,
      );
    }

    test('Adding an item should update currentItems list', () {
      final item = createMockItem('1', 100.0);
      service.addItem(item);
      
      expect(service.currentItems.length, 1);
      expect(service.currentItems.first.id, '1');
    });

    test('Subtotal should calculate the sum of all item subtotals correctly', () {
      service.addItem(createMockItem('1', 100.0));
      service.addItem(createMockItem('2', 250.0));
      
      // 100 + 250 = 350
      expect(service.subtotal, 350.0);
    });

    test('Store discount should be 0 if subtotal is below threshold', () {
      service.setStoreOffer(1000.0, 10.0); // 10% off if spend >= 1000
      service.addItem(createMockItem('1', 500.0));
      
      expect(service.storeDiscountAmount, 0.0);
      expect(service.finalTotalValue, 500.0);
    });

    test('Store discount should apply correctly when threshold is met', () {
      service.setStoreOffer(1000.0, 10.0); // 10% off if spend >= 1000
      service.addItem(createMockItem('1', 1200.0));
      
      // 10% of 1200 = 120
      expect(service.storeDiscountAmount, 120.0);
      expect(service.finalTotalValue, 1080.0);
    });

    test('Total Savings should include item savings, vendor savings, and store discount', () {
      service.setStoreOffer(500.0, 10.0); // 10% off if spend >= 500
      
      // Item 1: ₹300, Vendor Off: ₹50 -> Paid: ₹250, Saved: ₹50
      final item1 = createMockItem('1', 300.0, vendorDisc: 50.0);
      
      // Item 2: ₹300, Vendor Off: ₹0 -> Paid: ₹300, Saved: ₹0
      final item2 = createMockItem('2', 300.0);
      
      service.addItem(item1);
      service.addItem(item2);
      
      // Total before store offer = 250 + 300 = 550
      // Store discount (10% of 550) = 55
      // Total Savings = 50 (vendor) + 55 (store) = 105
      
      expect(service.totalBeforeStoreOffer, 550.0);
      expect(service.storeDiscountAmount, 55.0);
      expect(service.totalSavings, 105.0);
      expect(service.finalTotalValue, 495.0);
    });

    test('Removing an item should update totals correctly', () {
      final item1 = createMockItem('1', 100.0);
      final item2 = createMockItem('2', 200.0);
      
      service.addItem(item1);
      service.addItem(item2);
      expect(service.subtotal, 300.0);
      
      service.removeItem('1');
      expect(service.subtotal, 200.0);
      expect(service.currentItems.length, 1);
    });
  });
}
