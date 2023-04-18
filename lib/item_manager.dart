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
  ItemType type;
  bool isCompleted;
  bool isSoftDeadline;
  DateTime deadline;
  Duration timeSpent = const Duration();
  Duration estimatedLength;

  double urgency = 0;
  int category = 0;

  Item({
    required this.title,
    required this.description,
    required this.type,
    required this.deadline,
    this.isCompleted = false,
    required this.estimatedLength,
    this.isSoftDeadline = false,
  });

  void editTitle(String title) {
    this.title = title;
  }

  void editDescription(String description) {
    this.description = description;
  }

  void editType(ItemType type) {
    this.type = type;
  }

  void editCompleted(bool isCompleted) {
    this.isCompleted = isCompleted;
  }

  void editDeadline(bool isSoftDeadline, DateTime deadline) {
    this.isSoftDeadline = isSoftDeadline;
    this.deadline = deadline;
  }

  void editEstimatedLength(Duration estimatedLength) {
    this.estimatedLength = estimatedLength;
  }

  void incrementTimeSpent() {
    timeSpent = Duration(seconds: timeSpent.inSeconds + 1);
  }
}
