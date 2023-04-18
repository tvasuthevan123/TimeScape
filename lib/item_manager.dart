import 'dart:collection';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const timeLeeway = Duration(days: 3);

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
  }) {
    calculateUrgency();
  }

  void editTitle(String title) {
    this.title = title;
  }

  void editDescription(String description) {
    this.description = description;
  }

  void editType(ItemType type) {
    this.type = type;
    calculateUrgency();
  }

  void editCompleted(bool isCompleted) {
    this.isCompleted = isCompleted;
  }

  void editDeadline(bool isSoftDeadline, DateTime deadline) {
    this.isSoftDeadline = isSoftDeadline;
    this.deadline = deadline;
    calculateUrgency();
  }

  void editEstimatedLength(Duration estimatedLength) {
    this.estimatedLength = estimatedLength;
    calculateUrgency();
  }

  void incrementTimeSpent() {
    timeSpent = Duration(seconds: timeSpent.inSeconds + 1);
  }

  void calculateUrgency() {
    if (isCompleted || type != ItemType.task) return;

    double denominator = isSoftDeadline
        ? timeLeeway.inSeconds.toDouble() +
            deadline.difference(DateTime.now()).inSeconds.toDouble()
        : deadline.difference(DateTime.now()).inSeconds.toDouble();
    if (denominator == 0) {
      denominator = 1e-6; // set a small value
    }
    double x = log(1 +
        ((estimatedLength.inSeconds - timeSpent.inSeconds) /
                (deadline.difference(DateTime.now()).inSeconds)) /
            denominator);
    double calculatedUrgency = -1 + (2 / (1 + pow(e, (-8 * x + 2))));
    urgency = calculatedUrgency.clamp(0.0, 1.0);
  }
}
