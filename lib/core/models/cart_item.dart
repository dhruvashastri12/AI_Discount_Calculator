import 'package:flutter/material.dart';

enum PriceMode { flatRate, perUnit }
enum DiscountType { percentage, flat }

class CartItem {
  final String id;
  final String itemName;
  final String quantity; // For display, e.g. "500g"
  final String unitType; // Logical group: Weight, Volume, Count
  final PriceMode priceMode;
  final double enteredAmount;
  final double baseQty;
  final String baseUnit;
  final double boughtQty;
  final String boughtUnit;
  final double discountValue;
  final DiscountType discountType;
  final String categoryId;
  final DateTime date;
  final double vendorDiscountValue;
  final DiscountType vendorDiscountType;
  final int iconCode;
  final String marketType; // 'Local' or 'Mall'

  CartItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.unitType,
    required this.priceMode,
    required this.enteredAmount,
    required this.baseQty,
    required this.baseUnit,
    required this.boughtQty,
    required this.boughtUnit,
    required this.discountValue,
    required this.discountType,
    required this.categoryId,
    required this.date,
    required this.vendorDiscountValue,
    required this.vendorDiscountType,
    required this.iconCode,
    this.marketType = 'Local',
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  double get subtotal {
    if (priceMode == PriceMode.flatRate) {
      return enteredAmount;
    } else {
      double bQty = _normalize(boughtQty, boughtUnit);
      double bBase = _normalize(baseQty, baseUnit);
      return (bQty / bBase) * enteredAmount;
    }
  }

  double get itemFinalPrice {
    double discountAmount = 0;
    if (discountType == DiscountType.percentage) {
      discountAmount = subtotal * (discountValue / 100);
    } else {
      discountAmount = discountValue;
    }
    double result = subtotal - discountAmount;
    return result < 0 ? 0 : result;
  }

  double get vendorDiscountAmount {
    if (vendorDiscountType == DiscountType.percentage) {
      return itemFinalPrice * (vendorDiscountValue / 100);
    } else {
      return vendorDiscountValue;
    }
  }

  double get itemAfterVendorDiscount {
    double result = itemFinalPrice - vendorDiscountAmount;
    return result < 0 ? 0 : result;
  }

  double get totalSavings {
    double original = subtotal;
    return (original - itemAfterVendorDiscount).clamp(0, double.infinity);
  }

  double _normalize(double value, String unit) {
    String u = unit.toLowerCase();
    if (u == 'kg' || u == 'ltr') {
      return value * 1000;
    }
    return value;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemName': itemName,
        'quantity': quantity,
        'unitType': unitType,
        'priceMode': priceMode.name,
        'enteredAmount': enteredAmount,
        'baseQty': baseQty,
        'baseUnit': baseUnit,
        'boughtQty': boughtQty,
        'boughtUnit': boughtUnit,
        'discountValue': discountValue,
        'discountType': discountType.name,
        'categoryId': categoryId,
        'date': date.toIso8601String(),
        'vendorDiscountValue': vendorDiscountValue,
        'vendorDiscountType': vendorDiscountType.name,
        'iconCode': iconCode,
        'marketType': marketType,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        itemName: json['itemName'] ?? json['title'] ?? '',
        quantity: json['quantity'] ?? json['qty'] ?? '',
        unitType: json['unitType'] ?? 'Count',
        priceMode: PriceMode.values.firstWhere(
          (e) => e.name == (json['priceMode'] ?? 'flatRate'),
          orElse: () => PriceMode.flatRate,
        ),
        enteredAmount: (json['enteredAmount'] ?? json['unitPrice'] ?? 0.0).toDouble(),
        baseQty: (json['baseQty'] ?? 1.0).toDouble(),
        baseUnit: json['baseUnit'] ?? 'pcs',
        boughtQty: (json['boughtQty'] ?? json['rawQty'] ?? 1.0).toDouble(),
        boughtUnit: json['boughtUnit'] ?? json['unit'] ?? 'pcs',
        discountValue: (json['discountValue'] ?? 0.0).toDouble(),
        discountType: DiscountType.values.firstWhere(
          (e) => e.name == (json['discountType'] ?? 'percentage'),
          orElse: () => DiscountType.percentage,
        ),
        categoryId: json['categoryId'] ?? 'grocery',
        date: DateTime.parse(json['date']),
        vendorDiscountValue: (json['vendorDiscountValue'] ?? 0.0).toDouble(),
        vendorDiscountType: DiscountType.values.firstWhere(
          (e) => e.name == (json['vendorDiscountType'] ?? 'percentage'),
          orElse: () => DiscountType.percentage,
        ),
        iconCode: json['iconCode'] ?? 0,
        marketType: json['marketType'] ?? 'Local',
      );

  CartItem copyWith({
    String? id,
    String? itemName,
    String? quantity,
    String? unitType,
    PriceMode? priceMode,
    double? enteredAmount,
    double? baseQty,
    String? baseUnit,
    double? boughtQty,
    String? boughtUnit,
    double? discountValue,
    DiscountType? discountType,
    String? categoryId,
    DateTime? date,
    double? vendorDiscountValue,
    DiscountType? vendorDiscountType,
    int? iconCode,
    String? marketType,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitType: unitType ?? this.unitType,
      priceMode: priceMode ?? this.priceMode,
      enteredAmount: enteredAmount ?? this.enteredAmount,
      baseQty: baseQty ?? this.baseQty,
      baseUnit: baseUnit ?? this.baseUnit,
      boughtQty: boughtQty ?? this.boughtQty,
      boughtUnit: boughtUnit ?? this.boughtUnit,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      vendorDiscountValue: vendorDiscountValue ?? this.vendorDiscountValue,
      vendorDiscountType: vendorDiscountType ?? this.vendorDiscountType,
      iconCode: iconCode ?? this.iconCode,
      marketType: marketType ?? this.marketType,
    );
  }
}
