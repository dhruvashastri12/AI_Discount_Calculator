import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../constants/app_constants.dart';

/// Service responsible for managing shopping list data and history.
/// Follows the Singleton pattern to ensure data consistency across the app.
class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Observable state for UI updates
  List<CartItem> _currentItems = [];
  List<Map<String, dynamic>> _historyData = [];

  List<CartItem> get currentItems => _currentItems;
  List<Map<String, dynamic>> get historyData => _historyData;

  /// Initializes the service by loading stored data and checking for date changes.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load current items from persistent storage
    final currentStr = prefs.getString(AppConstants.keyCurrentItems) ?? '[]';
    final List decodedCurrent = jsonDecode(currentStr);
    _currentItems = decodedCurrent.map((e) => CartItem.fromJson(e)).toList();

    // Load history data from persistent storage
    final historyStr = prefs.getString(AppConstants.keyHistoryData) ?? '[]';
    final List decodedHistory = jsonDecode(historyStr);
    _historyData = List<Map<String, dynamic>>.from(decodedHistory);
    
    // Ensure history is correctly sorted: Date (Desc) then Total (Desc)
    _sortHistory();
    
    // Rule: If today's items are not present then only previous one day's items should be shown.
    _handleListingLogic();

    // Check if we need to seed dummy data for testing
    if (_currentItems.isEmpty && _historyData.isEmpty) {
      _seedDummyData();
    }
    
    notifyListeners();
  }

  /// Ensures the current list only shows today's items, or the most recent day's items if today is empty.
  void _handleListingLogic() {
    if (_currentItems.isEmpty) {
      // If empty, try to pull the absolute most recent day from history
      if (_historyData.isNotEmpty) {
        final lastHistoryDay = _historyData.first;
        final List details = lastHistoryDay['details'];
        _currentItems = details.map((e) => CartItem.fromJson(Map<String, dynamic>.from(e))).toList();
      }
      return;
    }

    final now = DateTime.now();
    final bool hasToday = _currentItems.any((item) => 
      item.date.year == now.year && item.date.month == now.month && item.date.day == now.day);

    if (hasToday) {
      _archiveNonTodayItems();
    } else {
      _currentItems.sort((a, b) => b.date.compareTo(a.date));
      final mostRecentDate = _currentItems.first.date;
      
      final recentDayItems = _currentItems.where((item) => 
        item.date.year == mostRecentDate.year && 
        item.date.month == mostRecentDate.month && 
        item.date.day == mostRecentDate.day).toList();
      
      final olderItems = _currentItems.where((item) => !recentDayItems.contains(item)).toList();
      
      if (olderItems.isNotEmpty) {
        _archiveItemsToHistory(olderItems);
        _currentItems = recentDayItems;
      }
    }
  }

  /// Seeds dummy data for testing purposes (Current list and April 7th history).
  void _seedDummyData() {
    final yesterday = DateTime(2026, 4, 7);
    
    _currentItems = [
      CartItem(
        id: 'seed_curr_1',
        title: 'Organic Eggs',
        qty: '12 pcs',
        price: 180.0,
        originalPrice: 200.0,
        discountLabel: '10% OFF',
        iconCode: Icons.egg_outlined.codePoint,
        date: yesterday,
        unitPrice: 16.66,
        rawQty: 12.0,
        unit: 'pcs',
        discountValue: 10.0,
        isPercent: true,
      ),
      CartItem(
        id: 'seed_curr_2',
        title: 'Brown Bread',
        qty: '1 unit',
        price: 45.0,
        iconCode: Icons.bakery_dining.codePoint,
        date: yesterday,
        unitPrice: 45.0,
        rawQty: 1.0,
        unit: 'unit',
      ),
      CartItem(
        id: 'seed_curr_3',
        title: 'Banana Bundle',
        qty: '1 kg',
        price: 60.0,
        originalPrice: 80.0,
        discountLabel: '₹20 OFF',
        iconCode: Icons.shopping_basket_outlined.codePoint,
        date: yesterday,
        unitPrice: 80.0,
        rawQty: 1.0,
        unit: 'kg',
        discountValue: 20.0,
        isPercent: false,
      ),
    ];

    final List<CartItem> historyItems = [
      CartItem(
        id: 'hist_1',
        title: 'Fresh Milk',
        qty: '2 litre',
        price: 120.0,
        iconCode: Icons.water_drop.codePoint,
        date: yesterday,
        unitPrice: 60.0,
        rawQty: 2.0,
        unit: 'litre',
      ),
      CartItem(
        id: 'hist_2',
        title: 'Tomato',
        qty: '1 kg',
        price: 40.0,
        iconCode: Icons.shopping_cart.codePoint,
        date: yesterday,
        unitPrice: 40.0,
        rawQty: 1.0,
        unit: 'kg',
      ),
      CartItem(
        id: 'hist_3',
        title: 'Eggs',
        qty: '1 dozen',
        price: 72.0,
        iconCode: Icons.shopping_cart.codePoint,
        date: yesterday,
        unitPrice: 72.0,
        rawQty: 1.0,
        unit: 'dozen',
      ),
    ];

    _historyData = [
      {
        'date': yesterday.toIso8601String(),
        'total': historyItems.fold(0.0, (sum, it) => sum + it.price),
        'items_count': historyItems.length,
        'details': historyItems.map((e) => e.toJson()).toList(),
      }
    ];

    _saveCurrent();
    _saveHistory();
  }

  void addItem(CartItem item) {
    final now = DateTime.now();
    final bool isToday = item.date.year == now.year && item.date.month == now.month && item.date.day == now.day;
    
    if (isToday) {
      _archiveNonTodayItems();
      _currentItems.insert(0, item);
    } else {
      final hasTodayItems = _currentItems.any((it) => 
        it.date.year == now.year && it.date.month == now.month && it.date.day == now.day);

      if (hasTodayItems) {
        _archiveItemsToHistory([item]);
      } else {
        _currentItems.insert(0, item);
      }
    }
    
    _saveCurrent();
    notifyListeners();
  }

  void _archiveNonTodayItems() {
    if (_currentItems.isEmpty) return;
    
    final now = DateTime.now();
    List<CartItem> notToday = _currentItems.where((item) => 
      !(item.date.year == now.year && item.date.month == now.month && item.date.day == now.day)
    ).toList();

    if (notToday.isNotEmpty) {
      _archiveItemsToHistory(notToday);
      _currentItems.removeWhere((item) => notToday.contains(item));
    }
  }

  void _archiveItemsToHistory(List<CartItem> items) {
     Map<String, List<CartItem>> grouped = {};
     for (var item in items) {
       final d = DateTime(item.date.year, item.date.month, item.date.day).toIso8601String();
       grouped.putIfAbsent(d, () => []).add(item);
     }

     grouped.forEach((dateStr, dateItems) {
       final existingDayIdx = _historyData.indexWhere((day) => day['date'] == dateStr);
       double dayTotal = dateItems.fold(0.0, (sum, it) => sum + it.price);
       
       if (existingDayIdx != -1) {
         final List details = List.from(_historyData[existingDayIdx]['details']);
         details.addAll(dateItems.map((e) => e.toJson()));
         _historyData[existingDayIdx]['details'] = details;
         _historyData[existingDayIdx]['items_count'] = details.length;
         _historyData[existingDayIdx]['total'] = (_historyData[existingDayIdx]['total'] as num).toDouble() + dayTotal;
       } else {
         _historyData.add({
           'date': dateStr,
           'total': dayTotal,
           'items_count': dateItems.length,
           'details': dateItems.map((e) => e.toJson()).toList(),
         });
       }
     });
     _sortHistory();
     _saveHistory();
  }

  Future<void> removeItem(String id, {bool alsoFromHistory = false}) async {
    _currentItems.removeWhere((item) => item.id == id);
    if (alsoFromHistory) {
      _removeItemFromHistoryData(id);
    }
    await _saveCurrent();
    await _saveHistory();
    notifyListeners();
  }

  void updateItem(CartItem updatedItem, {bool alsoInHistory = true}) {
    final index = _currentItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _currentItems[index] = updatedItem;
      _handleListingLogic();
      _saveCurrent();
    } else {
      final now = DateTime.now();
      if (updatedItem.date.year == now.year && updatedItem.date.month == now.month && updatedItem.date.day == now.day) {
        _currentItems.insert(0, updatedItem);
        _handleListingLogic();
        _saveCurrent();
      }
    }

    if (alsoInHistory) {
      _updateItemInHistoryData(updatedItem);
      _saveHistory();
    }
    notifyListeners();
  }

  bool checkItemInHistory(String id) {
    for (var day in _historyData) {
      final List details = day['details'];
      for (var item in details) {
        if (item is Map && item['id'] == id) return true;
      }
    }
    return false;
  }

  void _removeItemFromHistoryData(String id) {
    for (var i = 0; i < _historyData.length; i++) {
       final List details = List.from(_historyData[i]['details']);
       final int originalLen = details.length;
       details.removeWhere((item) => item is Map && item['id'] == id);
       
       if (details.length != originalLen) {
         _historyData[i]['details'] = details;
         _historyData[i]['items_count'] = details.length;
         double dailyTotal = details.fold(0.0, (sum, it) => sum + (it['price'] as num).toDouble());
         _historyData[i]['total'] = dailyTotal;
       }
    }
    _historyData.removeWhere((day) => day['items_count'] == 0);
  }

  void _updateItemInHistoryData(CartItem updatedItem) {
    for (var i = 0; i < _historyData.length; i++) {
       final List details = List.from(_historyData[i]['details']);
       bool dayChanged = false;
       for (var j = 0; j < details.length; j++) {
         if (details[j] is Map && details[j]['id'] == updatedItem.id) {
           details[j] = updatedItem.toJson();
           dayChanged = true;
         }
       }
       if (dayChanged) {
         _historyData[i]['details'] = details;
         double dailyTotal = details.fold(0.0, (sum, it) => sum + (it['price'] as num).toDouble());
         _historyData[i]['total'] = dailyTotal;
       }
    }
  }

  Future<void> clearCurrentAndAddToHistory({DateTime? archiveDate}) async {
    if (_currentItems.isEmpty) return;
    final double total = _currentItems.fold(0.0, (sum, item) => sum + item.price);
    _historyData.add({
      'date': (archiveDate ?? DateTime.now()).toIso8601String(),
      'total': total,
      'items_count': _currentItems.length,
      'details': _currentItems.map((e) => e.toJson()).toList(),
    });
    _sortHistory();
    _currentItems.clear();
    await _saveCurrent();
    await _saveHistory();
    notifyListeners();
  }

  void _sortHistory() {
    _historyData.sort((a, b) {
      final dateA = DateTime.parse(a['date']);
      final dateB = DateTime.parse(b['date']);
      int dateCompare = dateB.compareTo(dateA);
      if (dateCompare != 0) return dateCompare;
      final totalA = (a['total'] as num).toDouble();
      final totalB = (b['total'] as num).toDouble();
      return totalB.compareTo(totalA);
    });
  }

  Future<void> _saveCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrentItems, jsonEncode(_currentItems.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyHistoryData, jsonEncode(_historyData));
  }

  double getMonthlyTotal() {
    double total = 0;
    final now = DateTime.now();
    for (var record in _historyData) {
      final date = DateTime.parse(record['date']);
      if (date.month == now.month && date.year == now.year) {
        total += (record['total'] as num).toDouble();
      }
    }
    return total;
  }
}

final dataService = DataService();
