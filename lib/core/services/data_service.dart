// lib/core/services/data_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../constants/app_constants.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  List<CartItem> _allItems = [];
  
  double _storeThreshold = 0;
  double _storePercentage = 0;

  double get storeThreshold => _storeThreshold;
  double get storePercentage => _storePercentage;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    final currentStr = prefs.getString(AppConstants.keyCurrentItems) ?? '[]';
    final List decodedCurrent = jsonDecode(currentStr);
    _allItems = decodedCurrent.map((e) => CartItem.fromJson(e)).toList();

    _storeThreshold = prefs.getDouble('storeThreshold') ?? 0;
    _storePercentage = prefs.getDouble('storePercentage') ?? 0;

    notifyListeners();
  }

  /// Reset the service state (useful for testing and data clearing)
  void clear() {
    _allItems.clear();
    _storeThreshold = 0;
    _storePercentage = 0;
    _saveAll();
    notifyListeners();
  }

  /// Returns items for the most recent date that has entries, or empty list.
  List<CartItem> get currentItems {
    if (_allItems.isEmpty) return [];

    List<CartItem> sortedAll = List.from(_allItems);
    sortedAll.sort((a, b) {
      int comp = b.date.compareTo(a.date);
      if (comp == 0) return 0;
      return comp;
    });

    DateTime latestDate = sortedAll.first.date;
    DateTime latestDay = DateTime(latestDate.year, latestDate.month, latestDate.day);

    return sortedAll.where((item) {
      DateTime itemDay = DateTime(item.date.year, item.date.month, item.date.day);
      return itemDay.isAtSameMomentAs(latestDay);
    }).toList();
  }

  Map<DateTime, List<CartItem>> get historyByDate {
    Map<DateTime, List<CartItem>> grouped = {};
    for (var item in _allItems) {
      DateTime day = DateTime(item.date.year, item.date.month, item.date.day);
      grouped.putIfAbsent(day, () => []).add(item);
    }
    return grouped;
  }

  void setStoreOffer(double threshold, double percentage) async {
    _storeThreshold = threshold;
    _storePercentage = percentage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('storeThreshold', threshold);
    await prefs.setDouble('storePercentage', percentage);
    notifyListeners();
  }

  double get subtotal => currentItems.fold(0, (sum, it) => sum + it.subtotal);
  
  double get totalSavings {
    double itemSavings = currentItems.fold(0, (sum, it) => sum + (it.subtotal - it.itemFinalPrice));
    double vendorSavings = currentItems.fold(0, (sum, it) => sum + it.vendorDiscountAmount);
    return itemSavings + vendorSavings + storeDiscountAmount;
  }

  double get totalBeforeStoreOffer => currentItems.fold(0, (sum, it) => sum + it.itemAfterVendorDiscount);

  double get storeDiscountAmount {
    if (_storeThreshold > 0 && totalBeforeStoreOffer >= _storeThreshold) {
      return totalBeforeStoreOffer * (_storePercentage / 100);
    }
    return 0;
  }

  double get finalTotalValue => totalBeforeStoreOffer - storeDiscountAmount;

  double get allTimeExpense => _allItems.fold(0, (sum, it) => sum + it.itemAfterVendorDiscount);
  
  double get allTimeSavings => _allItems.fold(0, (sum, it) => sum + it.totalSavings);

  void addItem(CartItem item) {
    _allItems.insert(0, item);
    _saveAll();
    notifyListeners();
  }

  void removeItem(String id) {
    _allItems.removeWhere((it) => it.id == id);
    _saveAll();
    notifyListeners();
  }

  void updateItem(CartItem item) {
    int idx = _allItems.indexWhere((it) => it.id == item.id);
    if (idx != -1) {
      _allItems[idx] = item;
      _saveAll();
      notifyListeners();
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentItems, jsonEncode(_allItems.map((e) => e.toJson()).toList()));
  }

  Map<String, List<CartItem>> groupItemsByCategory(List<CartItem> items) {
    Map<String, List<CartItem>> grouped = {};
    for (var item in items) {
      grouped.putIfAbsent(item.categoryId, () => []).add(item);
    }
    return grouped;
  }
}

final dataService = DataService();
