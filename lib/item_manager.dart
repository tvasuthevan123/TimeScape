import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timescape/database_helper.dart';
import 'package:uuid/uuid.dart';

const timeLeeway = Duration(days: 3);

class ItemManager extends ChangeNotifier {
  /// Internal, private state of the cart.
  final Map<String, Item> _items = {};
  UnmodifiableMapView<String, Item> get items =>
      UnmodifiableMapView<String, Item>(_items);

  Future<void> loadItemsFromDatabase() async {
    final items = await DatabaseHelper().getItems();

    for (final item in items) {
      _items[item.id] = item;
    }

    notifyListeners();
  }

  void addItem(Item item) {
    _items[item.id] = item;
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
  String id;
  String title;
  String description;
  ItemType type;
  bool isCompleted;
  bool isSoftDeadline;
  DateTime deadline;
  Duration timeSpent = const Duration();
  Duration estimatedLength;

  double urgency = 0;
  double importance = 0;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.index,
      'is_completed': isCompleted ? 1 : 0,
      'is_soft_deadline': isSoftDeadline ? 1 : 0,
      'deadline': deadline.millisecondsSinceEpoch,
      'time_spent': timeSpent.inMilliseconds,
      'estimated_length': estimatedLength.inMilliseconds,
      'urgency': urgency,
      'importance': importance,
    };
  }

  static Item fromMap(Map<String, dynamic> map) {
    return Item(
      title: map['title'],
      description: map['description'],
      type: ItemType.values[map['type']],
      isCompleted: map['is_completed'] == 1,
      isSoftDeadline: map['is_soft_deadline'] == 1,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
      timeSpent: Duration(milliseconds: map['time_spent']),
      estimatedLength: Duration(milliseconds: map['estimated_length']),
      urgency: map['urgency'],
      importance: map['importance'],
      id: map['id'],
    );
  }

  Item({
    required this.title,
    required this.description,
    required this.type,
    required this.deadline,
    this.isCompleted = false,
    required this.estimatedLength,
    this.isSoftDeadline = false,
    this.id = '',
    this.timeSpent = Duration.zero,
    this.urgency = 0,
    this.importance = 0,
  }) {
    calculateUrgency();
    if (id == '') {
      id = const Uuid().v4();
    }
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

    print("Deadline: ${deadline}");
    print("Minutes to deadline: ${calculateMinutes(DateTime.now(), deadline)}");
    weightedUrgency();
  }

  int calculateMinutes(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  void weightedUrgency() {
    double weightLength = 1;
    double weightDeadline = 1;

    int timeTillDeadline = calculateMinutes(DateTime.now(), deadline);

    urgency = weightLength * estimatedLength.inMinutes +
        weightDeadline * timeTillDeadline;
  }
}
