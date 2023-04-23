import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:timescape/database_helper.dart';
import 'package:uuid/uuid.dart';

const timeLeeway = Duration(days: 3);

class EntryManager extends ChangeNotifier {
  /// Internal, private state of the cart.
  final Map<String, Entry> _entries = {};
  UnmodifiableMapView<String, Entry> get entries =>
      UnmodifiableMapView<String, Entry>(_entries);

  EntryManager({Key? key}) {
    _generateEntrys(1);
    _generateEntrys(2);
    _generateEntrys(5);
    _generateEntrys(8);
  }

  void _generateEntrys(int importance) {
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
        addEntry(Task(
          id: '',
          title: 'Entry $importance-$estimatedLength-$days',
          description: 'Description for item $importance-${i + 1}-${j + 1}',
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

//   List<List<String>> classifyEntrysIntoQuadrants() {
//     List<Entry> taskList = _items.values.toList();
//     List<List<String>> eisenhowerQuadrants = [
//       [], // Urgent & Important
//       [], // Not Urgent & Important
//       [], // Urgent & Not Important
//       [], // Not Urgent & Not Important
//     ];

//     // Normalize features
//     DateTime maxDeadline = taskList.fold(
//         taskList[0].deadline,
//         (prev, current) =>
//             current.deadline.isAfter(prev) ? current.deadline : prev);
//     Duration maxEstimatedLength = taskList.fold(
//         taskList[0].estimatedLength,
//         (prev, current) =>
//             current.estimatedLength > prev ? current.estimatedLength : prev);
//     double maxImportance = taskList.fold(
//         taskList[0].importance,
//         (prev, current) =>
//             current.importance > prev ? current.importance : prev);

//     Map<String, List<double>> normalizedEntrys = Map();
//     for (Entry item in taskList) {
//       double normalizedDeadline = _minMaxNormalization(
//           maxDeadline.difference(item.deadline).inMilliseconds.toDouble(),
//           0,
//           maxDeadline.difference(DateTime.now()).inMilliseconds.toDouble());
//       double normalizedEstimatedLength = _minMaxNormalization(
//           item.estimatedLength.inMilliseconds.toDouble(),
//           0,
//           maxEstimatedLength.inMilliseconds.toDouble());
//       double normalizedImportance =
//           _minMaxNormalization(item.importance, 0, maxImportance);

//       List<double> normalizedValues = [
//         normalizedDeadline,
//         normalizedEstimatedLength,
//         normalizedImportance,
//       ];

//       normalizedEntrys[item.id] = normalizedValues;
//     }

// // Calculate percentiles
//     List<List<double>> normalizedValuesList = normalizedEntrys.values.toList();

// // Sort by deadline
//     normalizedValuesList.sort((a, b) => a[0].compareTo(b[0]));
//     double urgencyP25 =
//         normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][0];
//     double urgencyP75 =
//         normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][0];

// // Sort by estimated length
//     normalizedValuesList.sort((a, b) => a[1].compareTo(b[1]));
//     double estimatedLengthP25 =
//         normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][1];
//     double estimatedLengthP75 =
//         normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][1];

// // Sort by importance
//     normalizedValuesList.sort((a, b) => a[2].compareTo(b[2]));
//     double importanceP25 =
//         normalizedValuesList[(normalizedValuesList.length * 0.25).floor()][2];
//     double importanceP75 =
//         normalizedValuesList[(normalizedValuesList.length * 0.75).floor()][2];

// // Define shadow centroids
//     List<List<double>> centroids = [
//       [urgencyP75, estimatedLengthP75, importanceP75], // Urgent & Important
//       [urgencyP25, estimatedLengthP25, importanceP75], // Not Urgent & Important
//       [urgencyP75, estimatedLengthP75, importanceP25], // Urgent & Not Important
//       [
//         urgencyP25,
//         estimatedLengthP25,
//         importanceP25
//       ], // Not Urgent & Not Important
//     ];

//     print("Centroids");
//     print(centroids);

// // Classify items into quadrants
//     List<String> itemIds = normalizedEntrys.keys.toList();
//     for (String itemId in itemIds) {
//       List<double> itemCoordinates = normalizedEntrys[itemId]!;
//       double minDistance = double.infinity;
//       int minIndex = 0;

//       for (int i = 0; i < centroids.length; i++) {
//         double distance = _euclideanDistance(itemCoordinates, centroids[i]);
//         if (distance < minDistance) {
//           minDistance = distance;
//           minIndex = i;
//         }
//       }

//       String quadrant = "Urgent, Important";
//       switch (minIndex) {
//         case 1:
//           quadrant = "Not Urgent, Important";
//           break;
//         case 2:
//           quadrant = "Urgent, Not Important";
//           break;
//         case 3:
//           quadrant = "Not Urgent, Not Important";
//           break;
//         default:
//           break;
//       }

//       print(
//           "${items[itemId]?.importance},${items[itemId]?.estimatedLength.inMinutes}min, ${items[itemId]?.deadline.difference(DateTime.now()).inDays}days, $quadrant");
//       // Assign the quadrant index (0-3) to the item
//       eisenhowerQuadrants[minIndex].add(itemId);
//     }

//     return eisenhowerQuadrants;
//   }

  List<List<String>> classifyTasksIntoQuadrants() {
    List<Task> taskList = _entries.values.whereType<Task>().toList();

    if (taskList.length < 10) {
      taskList.sort((a, b) => a.deadline.compareTo(b.deadline));
      return [taskList.map((item) => item.id).toList(), [], [], []];
    }

    List<List<String>> eisenhowerQuadrants = [
      [], // Urgent & Important
      [], // Not Urgent & Important
      [], // Urgent & Not Important
      [], // Not Urgent & Not Important
    ];

    double maxImportance = taskList.fold(
        taskList[0].importance,
        (prev, current) =>
            current.importance > prev ? current.importance : prev);

    Map<String, List<double>> itemFeatures = {};
    for (Task item in taskList) {
      double lengthToDeadlineRatio = item.estimatedLength.inMinutes /
          item.deadline.difference(DateTime.now()).inMinutes;
      double normalizedImportance =
          _minMaxNormalization(item.importance, 0, maxImportance);

      List<double> normalizedValues = [
        lengthToDeadlineRatio,
        normalizedImportance,
      ];

      itemFeatures[item.id] = normalizedValues;
    }

    // Calculate percentiles
    List<List<double>> itemFeatureList = itemFeatures.values.toList();

    // Sort by deadline
    itemFeatureList.sort((a, b) => a[0].compareTo(b[0]));
    double lengthToDeadlineRatioP25 =
        itemFeatureList[(itemFeatureList.length * 0.25).floor()][0];
    double lengthToDeadlineRatioP75 =
        itemFeatureList[(itemFeatureList.length * 0.75).floor()][0];

    // Sort by importance
    itemFeatureList.sort((a, b) => a[1].compareTo(b[1]));
    double importanceP25 =
        itemFeatureList[(itemFeatureList.length * 0.25).floor()][1];
    double importanceP75 =
        itemFeatureList[(itemFeatureList.length * 0.75).floor()][1];

    // Define shadow centroids
    List<List<double>> centroids = [
      [lengthToDeadlineRatioP75, importanceP75], // Urgent & Important
      [lengthToDeadlineRatioP25, importanceP75], // Not Urgent & Important
      [lengthToDeadlineRatioP75, importanceP25], // Urgent & Not Important
      [lengthToDeadlineRatioP25, importanceP25], // Not Urgent & Not Important
    ];

    // Classify items into quadrants
    List<String> itemIds = itemFeatures.keys.toList();
    for (String itemId in itemIds) {
      List<double> itemCoordinates = itemFeatures[itemId]!;
      double minDistance = double.infinity;
      int minIndex = 0;

      for (int i = 0; i < centroids.length; i++) {
        double distance = _euclideanDistance(itemCoordinates, centroids[i]);
        if (distance < minDistance) {
          minDistance = distance;
          minIndex = i;
        }
      }

      // String quadrant = "Urgent and Important";
      // switch (minIndex) {
      //   case 1:
      //     quadrant = "Not Urgent and Important";
      //     break;
      //   case 2:
      //     quadrant = "Urgent and Not Important";
      //     break;
      //   case 3:
      //     quadrant = "Not Urgent and Not Important";
      //     break;
      //   default:
      //     break;
      // }

      // print(
      //     "${items[itemId]?.importance},${items[itemId]?.estimatedLength.inMinutes}min, ${items[itemId]?.deadline.difference(DateTime.now()).inDays}days, $quadrant");
      // Assign the quadrant index (0-3) to the item
      eisenhowerQuadrants[minIndex].add(itemId);
    }

    for (List<String> quadrant in eisenhowerQuadrants) {
      quadrant.sort((a, b) {
        final taskA = entries[a] as Task;
        final taskB = entries[b] as Task;
        return taskA.deadline.compareTo(taskB.deadline);
      });
    }

    return eisenhowerQuadrants;
  }

  Future<void> loadEntrysFromDatabase() async {
    final tasks = await DatabaseHelper().getTasks();

    for (final tasks in tasks) {
      _entries[tasks.id] = tasks;
    }

    notifyListeners();
  }

  void addEntry(Entry item) {
    _entries[item.id] = item;
    notifyListeners();
  }

  void removeEntry(String itemId) {
    _entries.remove(itemId);
    notifyListeners();
  }

  Entry? getEntry(String itemId) {
    return _entries[itemId];
  }

  /// Removes all items from the cart.
  void removeAll() {
    _entries.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}

enum EntryType {
  task,
  reminder,
  event,
}

abstract class Entry {
  late String id;
  late String title;
  late String description;
  late EntryType type;

  Entry({
    String? id,
    required this.title,
    required this.description,
    required this.type,
  }) {
    if (id == '' || id == null) {
      this.id = const Uuid().v4();
    }
  }
}

class Task extends Entry {
  bool isCompleted;
  bool isSoftDeadline;
  DateTime deadline;
  Duration timeSpent = const Duration();
  Duration estimatedLength;

  double urgency = 0;
  double importance = 0;

  Task({
    String? id,
    required String title,
    required String description,
    required this.deadline,
    required this.estimatedLength,
    this.isCompleted = false,
    this.isSoftDeadline = false,
    this.timeSpent = Duration.zero,
    this.urgency = 0,
    this.importance = 0,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: EntryType.task,
        ) {
    calculateUrgency();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'is_soft_deadline': isSoftDeadline ? 1 : 0,
      'deadline': deadline.millisecondsSinceEpoch,
      'time_spent': timeSpent.inMilliseconds,
      'estimated_length': estimatedLength.inMilliseconds,
      'urgency': urgency,
      'importance': importance,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
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
    if (isCompleted) return;

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

class Reminder extends Entry {
  DateTime time;

  Reminder({
    String? id,
    required String title,
    required String description,
    required this.time,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: EntryType.reminder,
        );
}

class Event extends Entry {
  DateTime startTime;
  Duration length;
  Recurrence recurrence;
  Duration reminderTimeBeforeEvent;

  Event({
    String? id,
    required String title,
    required String description,
    required this.startTime,
    required this.length,
    required this.recurrence,
    required this.reminderTimeBeforeEvent,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: EntryType.event,
        );
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

class Recurrence {
  RecurrenceType type;
  List<int> daysOfWeek;
  int interval;

  Recurrence({
    required this.type,
    required this.daysOfWeek,
    required this.interval,
  });
}
