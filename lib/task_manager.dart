import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CartModel extends ChangeNotifier {
  /// Internal, private state of the cart.
  final Map<String, Task> _tasks = {};
  UnmodifiableMapView<String, Task> get tasks =>
      UnmodifiableMapView<String, Task>(_tasks);

  void addTask(Task task) {
    _tasks[const Uuid().v4()] = task;
    notifyListeners();
  }

  void removeTask(String taskId) {
    _tasks.remove(taskId);
    notifyListeners();
  }

  Task? getTask(String taskId) {
    return _tasks[taskId];
  }

  /// Removes all items from the cart.
  void removeAll() {
    _tasks.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}

class Task {
  final String title;
  final String description;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}
