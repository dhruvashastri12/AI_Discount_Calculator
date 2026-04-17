import 'package:flutter/material.dart';

enum PriceMode { flat, perUnit }

enum DiscountType { percentage, amount }

class CartItem {
  final String id;
  final String title;
  final String qty;
  final double price; // Final calculated price after item-level discounts
  final double? originalPrice;
  final String? discountLabel;
  final int iconCode;
  final DateTime date;

  // Real-world scenario fields
  final PriceMode priceMode;
  final String categoryId;
  final DiscountType discountType;
  final double discountValue;
  final double unitPrice;
  final double rawQty;
  final String unit;

  CartItem({
    required this.id,
    required this.title,
    required this.qty,
    required this.price,
    this.originalPrice,
    this.discountLabel,
    required this.iconCode,
    DateTime? date,
    required this.priceMode,
    required this.categoryId,
    required this.discountType,
    required this.discountValue,
    required this.unitPrice,
    required this.rawQty,
    required this.unit,
  }) : date = date ?? DateTime.now();

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'qty': qty,
        'price': price,
        'originalPrice': originalPrice,
        'discountLabel': discountLabel,
        'iconCode': iconCode,
        'date': date.toIso8601String(),
        'priceMode': priceMode.name,
        'categoryId': categoryId,
        'discountType': discountType.name,
        'discountValue': discountValue,
        'unitPrice': unitPrice,
        'rawQty': rawQty,
        'unit': unit,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        title: json['title'],
        qty: json['qty'],
        price: (json['price'] as num).toDouble(),
        originalPrice: json['originalPrice'] != null
            ? (json['originalPrice'] as num).toDouble()
            : null,
        discountLabel: json['discountLabel'],
        iconCode: json['iconCode'],
        date: DateTime.parse(json['date']),
        priceMode: PriceMode.values.firstWhere(
          (e) => e.name == (json['priceMode'] ?? 'flat'),
          orElse: () => PriceMode.flat,
        ),
        categoryId: json['categoryId'] ?? 'uncategorized',
        discountType: DiscountType.values.firstWhere(
          (e) => e.name == (json['discountType'] ?? 'percentage'),
          orElse: () => DiscountType.percentage,
        ),
        discountValue: (json['discountValue'] as num? ?? 0).toDouble(),
        unitPrice: (json['unitPrice'] as num? ?? 0).toDouble(),
        rawQty: (json['rawQty'] as num? ?? 1).toDouble(),
        unit: json['unit'] ?? 'pcs',
      );
}


