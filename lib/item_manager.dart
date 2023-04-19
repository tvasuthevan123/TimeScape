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

    int minutesToDeadline = calculateWorkingMinutes(
      DateTime.now(),
      deadline,
    );

    print("Minutes to deadline: ${minutesToDeadline}");
    double x = 0.5 -
        (1 / (12 * log(2))) *
            log((minutesToDeadline) / (5 * estimatedLength.inMinutes));

    double calculatedUrgency = -1 + (2 / (1 + pow(e, 0.5 + (-6 * x))));
    print("Urgency ${calculatedUrgency}");
    urgency = calculatedUrgency.clamp(0.0, 1.0);
  }

  int calculateWorkingMinutes(DateTime start, DateTime end) {
    // Make sure the start time is earlier than the end time
    if (start.isAfter(end)) {
      final temp = start;
      start = end;
      end = temp;
    }

    int workingMinutes = 0;

    // Calculate the number of minutes in the first partial day
    final startTomorrow = DateTime(start.year, start.month, start.day + 1, 9);
    final endToday = DateTime(start.year, start.month, start.day, 17);
    final minutesToday = endToday.difference(start).inMinutes;
    final minutesFirstPartialDay = minutesToday > 0 ? minutesToday : 0;

    // Calculate the number of minutes in the last partial day
    final endYesterday = DateTime(end.year, end.month, end.day - 1, 17);
    final startNextDay = DateTime(end.year, end.month, end.day, 9);
    final minutesLastPartialDay = end.difference(endYesterday).inMinutes +
        (startNextDay.isBefore(end)
            ? startNextDay.difference(endYesterday).inMinutes
            : 0);

    // Calculate the number of minutes in each full day
    final fullDayStart = startTomorrow;
    final fullDayEnd = endYesterday;
    final fullDaysBetween = fullDayEnd.difference(fullDayStart).inDays + 1;
    const minutesPerDay = (5 - 9) * 60; // 8 hours per day

    workingMinutes = minutesFirstPartialDay + minutesLastPartialDay;
    workingMinutes += fullDaysBetween * minutesPerDay;

    return workingMinutes;
  }
}
