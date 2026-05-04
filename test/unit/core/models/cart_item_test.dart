// test/unit/core/models/cart_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_discount_calculator/core/models/cart_item.dart';

void main() {
  group('CartItem Business Logic Tests', () {
    final DateTime mockDate = DateTime(2024, 1, 1);

    test('Price calculation for flat rate mode should return entered amount as subtotal', () {
      final item = CartItem(
        id: '1',
        itemName: 'Bread',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: 50.0,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 0.0,
        discountType: DiscountType.percentage,
        categoryId: 'grocery',
        date: mockDate,
        vendorDiscountValue: 0.0,
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      expect(item.subtotal, 50.0);
    });

    test('Price calculation for per unit mode with same unit family (pcs) should scale correctly', () {
      final item = CartItem(
        id: '2',
        itemName: 'Apple',
        quantity: '5 pcs',
        unitType: 'Count',
        priceMode: PriceMode.perUnit,
        enteredAmount: 100.0, // ₹100
        baseQty: 10.0,        // per 10 pcs
        baseUnit: 'pcs',
        boughtQty: 5.0,       // bought 5 pcs
        boughtUnit: 'pcs',
        discountValue: 0.0,
        discountType: DiscountType.percentage,
        categoryId: 'grocery',
        date: mockDate,
        vendorDiscountValue: 0.0,
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      // (5 / 10) * 100 = 50
      expect(item.subtotal, 50.0);
    });

    test('Price calculation for per unit mode with unit conversion (g to kg) should normalize units', () {
      final item = CartItem(
        id: '3',
        itemName: 'Sugar',
        quantity: '500g',
        unitType: 'Weight',
        priceMode: PriceMode.perUnit,
        enteredAmount: 40.0,  // ₹40
        baseQty: 1.0,         // per 1 kg
        baseUnit: 'kg',
        boughtQty: 500.0,     // bought 500 g
        boughtUnit: 'g',
        discountValue: 0.0,
        discountType: DiscountType.percentage,
        categoryId: 'grocery',
        date: mockDate,
        vendorDiscountValue: 0.0,
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      // 500g normalized = 500. 1kg normalized = 1000.
      // (500 / 1000) * 40 = 20
      expect(item.subtotal, 20.0);
    });

    test('Discount calculation for percentage type should subtract correct amount from subtotal', () {
      final item = CartItem(
        id: '4',
        itemName: 'Shirt',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: 1000.0,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 10.0, // 10% off
        discountType: DiscountType.percentage,
        categoryId: 'clothing',
        date: mockDate,
        vendorDiscountValue: 0.0,
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      expect(item.itemFinalPrice, 900.0);
    });

    test('Discount calculation for flat amount type should subtract fixed value from subtotal', () {
      final item = CartItem(
        id: '5',
        itemName: 'Shoes',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: 1000.0,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 150.0, // ₹150 off
        discountType: DiscountType.flat,
        categoryId: 'clothing',
        date: mockDate,
        vendorDiscountValue: 0.0,
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      expect(item.itemFinalPrice, 850.0);
    });

    test('Vendor merchant discount calculation should apply to the price after item discount', () {
      final item = CartItem(
        id: '6',
        itemName: 'Phone',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: 10000.0,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 10.0, // 10% item discount -> 9000
        discountType: DiscountType.percentage,
        categoryId: 'electronics',
        date: mockDate,
        vendorDiscountValue: 500.0, // ₹500 vendor discount
        vendorDiscountType: DiscountType.flat,
        iconCode: 0,
      );

      expect(item.itemFinalPrice, 9000.0);
      expect(item.vendorDiscountAmount, 500.0);
      expect(item.itemAfterVendorDiscount, 8500.0);
    });

    test('Final total savings should include both item and vendor discounts', () {
      final item = CartItem(
        id: '7',
        itemName: 'Laptop',
        quantity: '1',
        unitType: 'Count',
        priceMode: PriceMode.flatRate,
        enteredAmount: 50000.0,
        baseQty: 1.0,
        baseUnit: 'pcs',
        boughtQty: 1.0,
        boughtUnit: 'pcs',
        discountValue: 5000.0, // ₹5000 item off -> 45000
        discountType: DiscountType.flat,
        categoryId: 'electronics',
        date: mockDate,
        vendorDiscountValue: 10.0, // 10% vendor off on 45000 -> 4500
        vendorDiscountType: DiscountType.percentage,
        iconCode: 0,
      );

      // Subtotal = 50000
      // Final Paid = 45000 - 4500 = 40500
      // Total Savings = 50000 - 40500 = 9500
      expect(item.itemAfterVendorDiscount, 40500.0);
      expect(item.totalSavings, 9500.0);
    });
  });
}
