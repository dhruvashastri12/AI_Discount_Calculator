import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final String qty;
  final double price;
  final double? originalPrice;
  final String? discountLabel;
  final int iconCode;
  final DateTime date;

  // Raw fields for editing
  final double? unitPrice;
  final double? rawQty;
  final String? unit;
  final double? discountValue;
  final bool? isPercent;

  CartItem({
    required this.id,
    required this.title,
    required this.qty,
    required this.price,
    this.originalPrice,
    this.discountLabel,
    required this.iconCode,
    DateTime? date,
    this.unitPrice,
    this.rawQty,
    this.unit,
    this.discountValue,
    this.isPercent,
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
        'unitPrice': unitPrice,
        'rawQty': rawQty,
        'unit': unit,
        'discountValue': discountValue,
        'isPercent': isPercent,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        title: json['title'],
        qty: json['qty'],
        price: json['price'],
        originalPrice: json['originalPrice'],
        discountLabel: json['discountLabel'],
        iconCode: json['iconCode'],
        date: DateTime.parse(json['date']),
        unitPrice: json['unitPrice'],
        rawQty: json['rawQty'],
        unit: json['unit'],
        discountValue: json['discountValue'],
        isPercent: json['isPercent'],
      );
}

