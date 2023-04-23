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

  ItemManager({Key? key}) {
    _generateItems(1);
    _generateItems(2);
    _generateItems(5);
    _generateItems(8);
  }

  void _generateItems(int importance) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 4; j++) {
        int estimatedLength = (i + 1) * 5;
        int days = 4;

        switch (j) {
          case 1:
            days = 8;
            break;
          case 2:
            days = 12;
            break;
          case 3:
            days = 20;
            break;
        }

        DateTime deadline = DateTime.now().add(Duration(days: days));
        addItem(Item(
          title: 'Item $importance-$estimatedLength-$days',
          description: 'Description for item $importance-${i + 1}-${j + 1}',
          type: ItemType.task,
          isCompleted: false,
          isSoftDeadline: true,
          deadline: deadline,
          estimatedLength: Duration(minutes: estimatedLength),
          importance: importance.toDouble(),
        ));
      }
    }
  }

  double _minMaxNormalization(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  double _euclideanDistance(List<double> pointA, List<double> pointB) {
    double sum = 0;
    for (int i = 0; i < pointA.length; i++) {
      sum += pow(pointA[i] - pointB[i], 2);
    }
    return sqrt(sum);
  }

  List<List<String>> classifyItemsIntoQuadrants() {
    List<Item> itemList = _items.values.toList();
    List<List<String>> eisenhowerQuadrants = [
      [], // Urgent & Important
      [], // Not Urgent & Important
      [], // Urgent & Not Important
      [], // Not Urgent & Not Important
    ];

    // Normalize features
    DateTime maxDeadline = itemList.fold(
        itemList[0].deadline,
        (prev, current) =>
            current.deadline.isAfter(prev) ? current.deadline : prev);
    Duration maxEstimatedLength = itemList.fold(
        itemList[0].estimatedLength,
        (prev, current) =>
            current.estimatedLength > prev ? current.estimatedLength : prev);
    double maxImportance = itemList.fold(
        itemList[0].importance,
        (prev, current) =>
            current.importance > prev ? current.importance : prev);

    Map<String, List<double>> normalizedItems = Map();
    for (Item item in itemList) {
      double normalizedDeadline = _minMaxNormalization(
          maxDeadline.difference(item.deadline).inMilliseconds.toDouble(),
          0,
          maxDeadline.difference(DateTime.now()).inMilliseconds.toDouble());
      double normalizedEstimatedLength = _minMaxNormalization(
          item.estimatedLength.inMilliseconds.toDouble(),
          0,
          maxEstimatedLength.inMilliseconds.toDouble());
      double normalizedImportance =
          _minMaxNormalization(item.importance, 0, maxImportance);

      List<double> normalizedValues = [
        normalizedDeadline,
        normalizedEstimatedLength,
        normalizedImportance,
      ];

      normalizedItems[item.id] = normalizedValues;
    }

// Calculate percentiles
    List<List<double>> normalizedValuesList = normalizedItems.values.toList();

// Sort by deadline
    normalizedValuesList.sort((a, b) => a[0].compareTo(b[0]));
    double urgencyP25 =
        normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][0];
    double urgencyP75 =
        normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][0];

// Sort by estimated length
    normalizedValuesList.sort((a, b) => a[1].compareTo(b[1]));
    double estimatedLengthP25 =
        normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][1];
    double estimatedLengthP75 =
        normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][1];

// Sort by importance
    normalizedValuesList.sort((a, b) => a[2].compareTo(b[2]));
    double importanceP25 =
        normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][2];
    double importanceP75 =
        normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][2];

// Define shadow centroids
    List<List<double>> centroids = [
      [urgencyP75, estimatedLengthP75, importanceP75], // Urgent & Important
      [urgencyP25, estimatedLengthP25, importanceP75], // Not Urgent & Important
      [urgencyP75, estimatedLengthP75, importanceP25], // Urgent & Not Important
      [
        urgencyP25,
        estimatedLengthP25,
        importanceP25
      ], // Not Urgent & Not Important
    ];

    print("Centroids");
    print(centroids);

// Classify items into quadrants
    List<String> itemIds = normalizedItems.keys.toList();
    for (String itemId in itemIds) {
      List<double> itemCoordinates = normalizedItems[itemId]!;
      double minDistance = double.infinity;
      int minIndex = 0;

      for (int i = 0; i < centroids.length; i++) {
        double distance = _euclideanDistance(itemCoordinates, centroids[i]);
        if (distance < minDistance) {
          minDistance = distance;
          minIndex = i;
        }
      }

      String quadrant = "Urgent and Important";
      switch (minIndex) {
        case 1:
          quadrant = "Not Urgent and Important";
          break;
        case 2:
          quadrant = "Urgent and Not Important";
          break;
        case 3:
          quadrant = "Not Urgent and Not Important";
          break;
        default:
          break;
      }

      print("${items[itemId]?.title} - $quadrant");
      // Assign the quadrant index (0-3) to the item
      eisenhowerQuadrants[minIndex].add(itemId);
    }

    return eisenhowerQuadrants;
  }

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

  List<List<String>> sortItemsByEisenhowerMatrix({int maxIterations = 10}) {
    // Define the number of clusters and maximum iterations
    const int numClusters = 4;

    // Initialize the clusters with random values
    final List<List<Item>> clusters = [];
    for (int i = 0; i < numClusters; i++) {
      clusters.add([]);
    }

    // Define the distance function to calculate the distance between two items
    double distance(Item item1, Item item2) {
      double urgencyDiff = item1.urgency - item2.urgency;
      double importanceDiff = item1.importance - item2.importance;
      return sqrt(pow(urgencyDiff, 2) + pow(importanceDiff, 2));
    }

// Initialize the cluster centers with random data points
    final List<Item> initialCenters = _items.values.toList()..shuffle();
    for (int i = 0; i < numClusters; i++) {
      clusters[i].add(initialCenters[i]);
    }

// Iterate until convergence or maximum iterations are reached
    int iteration = 0;
    bool converged = false;
    while (!converged && iteration < maxIterations) {
      iteration++;

      // Assign each item to the closest cluster
      for (final item in _items.values) {
        double minDistance = double.infinity;
        int closestClusterIndex = 0;
        for (int i = 0; i < numClusters; i++) {
          double clusterDistance = distance(item, clusters[i].first);
          if (clusterDistance < minDistance) {
            minDistance = clusterDistance;
            closestClusterIndex = i;
          }
        }
        clusters[closestClusterIndex].add(item);
      }

      // Update the urgency and importance values of each cluster based on the items
      bool centersChanged = false;
      for (int i = 0; i < numClusters; i++) {
        double sumUrgency = 0;
        double sumImportance = 0;
        for (final item in clusters[i]) {
          sumUrgency += item.urgency;
          sumImportance += item.importance;
        }
        int clusterSize = clusters[i].length;
        if (clusterSize > 0) {
          double averageUrgency = sumUrgency / clusterSize;
          double averageImportance = sumImportance / clusterSize;
          if (clusters[i].first.urgency != averageUrgency ||
              clusters[i].first.importance != averageImportance) {
            centersChanged = true;
          }
          clusters[i].first.urgency = averageUrgency;
          clusters[i].first.importance = averageImportance;
        }
      }

      // Check convergence based on cluster center changes
      if (!centersChanged) {
        converged = true;
      } else {
        // Clear the clusters for the next iteration
        for (int i = 0; i < numClusters; i++) {
          clusters[i].clear();
          clusters[i].add(initialCenters[i]);
        }
      }
    }

    // Create 4 lists of strings, each containing the IDs of the items in that quadrant
    final List<String> quadrant1 = [];
    final List<String> quadrant2 = [];
    final List<String> quadrant3 = [];
    final List<String> quadrant4 = [];

    for (final item in _items.values) {
      double minDistance = double.infinity;
      int closestClusterIndex = 0;
      for (int i = 0; i < numClusters; i++) {
        double clusterDistance = distance(item, clusters[i].first);
        if (clusterDistance < minDistance) {
          minDistance = clusterDistance;
          closestClusterIndex = i;
        }
      }
      switch (closestClusterIndex) {
        case 0:
          quadrant1.add(item.id);
          break;
        case 1:
          quadrant2.add(item.id);
          break;
        case 2:
          quadrant3.add(item.id);
          break;
        case 3:
          quadrant4.add(item.id);
          break;
      }
    }

    // Return the 4 lists of IDs
    return [quadrant1, quadrant2, quadrant3, quadrant4];
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
      'id': id,
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
