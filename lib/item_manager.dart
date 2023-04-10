import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ItemManager extends ChangeNotifier {
  /// Internal, private state of the cart.
  final Map<String, Item> _items = {};
  UnmodifiableMapView<String, Item> get items =>
      UnmodifiableMapView<String, Item>(_items);

  void addItem(Item item) {
    _items[const Uuid().v4()] = item;
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  Item? getItem(String itemId) {
    return _items[itemId];
  }

  /// Removes all items from the cart.
  void removeAll() {
    _items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}

enum ItemType { task, reminder }

class Item {
  String title;
  String description;
  ItemType itemType;
  bool isCompleted;
  Duration timeSpent = const Duration();

  Item({
    required this.title,
    required this.description,
    required this.itemType,
    this.isCompleted = false,
  });
}
