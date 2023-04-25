import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/scheduler.dart';
import 'package:uuid/uuid.dart';

const timeLeeway = Duration(days: 3);

class EntryManager extends ChangeNotifier {
  /// Internal, private state of the cart.

  TimeOfDay startWorkTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endWorkTime = const TimeOfDay(hour: 17, minute: 0);
  final Map<String, Entry> _entries = {};
  final List<TaskCategory> categories = [];
  UnmodifiableMapView<String, Entry> get entries =>
      UnmodifiableMapView<String, Entry>(_entries);

  EntryManager({Key? key}) {
    // _generateEntrys(1);
    // _generateEntrys(2);
    // _generateEntrys(5);
    // _generateEntrys(8);
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
          categoryID: 0,
        ));
      }
    }
  }

  Future<List<Event>> getEventsToday() async {
    List<String> eventsTodayIDs = await DatabaseHelper().getTodayEventIDs();
    return entries.values
        .where(
          (element) => eventsTodayIDs.contains(element.id),
        )
        .toList()
        .cast<Event>();
  }

  Future<List<TimeBlock>> getFreeTimeBlocksToday(
      List<Event> eventsToday) async {
    final List<TimeBlock> timeBlocks = [];

    print("Start Work Time: ${startWorkTime}");
    print("End Work Time: ${endWorkTime}");

    final startWorkTimeInMinutes =
        startWorkTime.hour * 60 + startWorkTime.minute;
    final endWorkTimeInMinutes = endWorkTime.hour * 60 + endWorkTime.minute;

    int previousEventEndInMinutes = startWorkTimeInMinutes;

    for (var i = 0; i < eventsToday.length; i++) {
      final event = eventsToday[i];
      print(
          "Event - ${event.startTime} and duration ${event.length.inMinutes}");
      final eventStartInMinutes =
          event.startTime.hour * 60 + event.startTime.minute;
      final eventEndInMinutes = eventStartInMinutes + event.length.inMinutes;

      if (eventStartInMinutes > previousEventEndInMinutes) {
        timeBlocks.add(TimeBlock(
          time: DateTime(
              event.startDate.year,
              event.startDate.month,
              event.startDate.day,
              previousEventEndInMinutes ~/ 60,
              previousEventEndInMinutes % 60),
          duration: Duration(
              minutes: eventStartInMinutes - previousEventEndInMinutes),
        ));
      }

      previousEventEndInMinutes = eventEndInMinutes;

      if (i == eventsToday.length - 1 &&
          eventEndInMinutes < endWorkTimeInMinutes) {
        timeBlocks.add(TimeBlock(
          time: DateTime(
              event.startDate.year,
              event.startDate.month,
              event.startDate.day,
              eventEndInMinutes ~/ 60,
              eventEndInMinutes % 60),
          duration: Duration(minutes: endWorkTimeInMinutes - eventEndInMinutes),
        ));
      }
    }

    if (previousEventEndInMinutes < endWorkTimeInMinutes) {
      timeBlocks.add(TimeBlock(
        time: DateTime(
            eventsToday.last.startDate.year,
            eventsToday.last.startDate.month,
            eventsToday.last.startDate.day,
            previousEventEndInMinutes ~/ 60,
            previousEventEndInMinutes % 60),
        duration:
            Duration(minutes: endWorkTimeInMinutes - previousEventEndInMinutes),
      ));
    }

    return timeBlocks;
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

    List<double> importanceVals = taskList
        .map((e) => categories
            .firstWhere((category) => e.categoryID == category.id)
            .value
            .toDouble())
        .toList();

    double maxImportance = importanceVals.fold(
        0, (prev, current) => current > prev ? current : prev);

    Map<String, List<double>> itemFeatures = {};
    for (Task item in taskList) {
      double lengthToDeadlineRatio = item.estimatedLength.inMinutes /
          item.deadline.difference(DateTime.now()).inMinutes;
      double normalizedImportance = _minMaxNormalization(
          categories
              .firstWhere((category) => item.categoryID == category.id)
              .value
              .toDouble(),
          0,
          maxImportance);

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

  void addCategory(TaskCategory category) {
    categories.add(category);
    notifyListeners();
  }

  void removeCategory(int id) {
    categories.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  Future<void> setStartWorkTime(int startMinutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('startWorkMinutes', startMinutes);
    startWorkTime =
        TimeOfDay(hour: startMinutes ~/ 60, minute: startMinutes % 60);
    notifyListeners();
  }

  Future<void> setEndWorkTime(int endMinutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('endWorkMinutes', endMinutes);
    endWorkTime = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);
    notifyListeners();
  }

  Future<void> loadPersistentDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int startWorkMinutes = prefs.getInt('startWorkMinutes') ?? -1;
    if (startWorkMinutes != -1) {
      startWorkTime = TimeOfDay(
          hour: startWorkMinutes ~/ 60, minute: startWorkMinutes % 60);
    }

    int endWorkMinutes = prefs.getInt('endWorkMinutes') ?? -1;
    if (endWorkMinutes != -1) {
      endWorkTime =
          TimeOfDay(hour: endWorkMinutes ~/ 60, minute: endWorkMinutes % 60);
    }

    final tasks = await DatabaseHelper().getTasks();

    for (final task in tasks) {
      _entries[task.id] = task;
    }

    final reminders = await DatabaseHelper().getReminders();

    for (final reminder in reminders) {
      _entries[reminder.id] = reminder;
    }

    final events = await DatabaseHelper().getEvents();

    for (final event in events) {
      _entries[event.id] = event;
    }

    final categories = await DatabaseHelper().getCategories();

    for (final category in categories) {
      this.categories.add(category);
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
    } else {
      this.id = id;
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
  // double importance = 0;

  int categoryID = 0;

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
    required this.categoryID,
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
      'deadline': deadline.millisecondsSinceEpoch,
      'time_spent': timeSpent.inMilliseconds,
      'estimated_length': estimatedLength.inMilliseconds,
      'urgency': urgency,
      'category': categoryID
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'],
      description: map['description'],
      isCompleted: map['is_completed'] == 1,
      deadline: DateTime.fromMillisecondsSinceEpoch(map['deadline']),
      timeSpent: Duration(milliseconds: map['time_spent']),
      estimatedLength: Duration(milliseconds: map['estimated_length']),
      urgency: map['urgency'],
      categoryID: map['category'],
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
  DateTime dateTime;

  Reminder({
    String? id,
    required String title,
    required String description,
    required this.dateTime,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: EntryType.reminder,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.millisecondsSinceEpoch,
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTime']),
    );
  }
}

class Event extends Entry {
  DateTime startDate; // date without time
  TimeOfDay startTime; // time without date
  Duration length;
  Recurrence recurrence;
  Duration reminderTimeBeforeEvent;

  Event({
    String? id,
    required String title,
    required String description,
    required this.startDate,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.millisecondsSinceEpoch,
      'startTime': "${startTime.hour}, ${startTime.minute}",
      'length': length.inMinutes,
      'reminderTimeBeforeEvent': reminderTimeBeforeEvent.inMinutes,
      'recurrenceType': recurrence.type.toString().split('.').last,
      'daysOfWeek': recurrence.daysOfWeek.join(','),
      'dayOfMonth': recurrence.dayOfMonth,
      'interval': recurrence.interval,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    List<String> daysOfWeekList = (map['daysOfWeek'] as String).split(',');
    if (daysOfWeekList.isNotEmpty) daysOfWeekList.removeLast();
    List<int> daysOfWeekIntList =
        daysOfWeekList.map((day) => int.parse(day)).toList();

    print("Event Map $map");
    List<int> startTimeParams = ((map['startTime'] as String).split(','))
        .map((e) => int.parse(e))
        .toList();

    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime:
          TimeOfDay(hour: startTimeParams[0], minute: startTimeParams[1]),
      startDate: DateTime.fromMicrosecondsSinceEpoch(map['startDate']),
      length: Duration(minutes: map['length']),
      reminderTimeBeforeEvent:
          Duration(minutes: map['reminderTimeBeforeEvent']),
      recurrence: Recurrence(
        type: RecurrenceType.values.firstWhere(
          (type) => type.toString().split('.').last == map['recurrenceType'],
        ),
        daysOfWeek: daysOfWeekIntList,
        dayOfMonth: map['dayOfMonth'],
        interval: map['interval'],
      ),
    );
  }
}

enum RecurrenceType { oneOff, daily, weekly, custom }

class Recurrence {
  final RecurrenceType type;
  final List<int> daysOfWeek;
  final int dayOfMonth;
  final int interval;

  Recurrence({
    required this.type,
    required this.daysOfWeek,
    this.dayOfMonth = 0,
    required this.interval,
  });
}

class TaskCategory {
  final String name;
  final int value;
  int id = 0;

  TaskCategory({
    required this.name,
    required this.value,
    this.id = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }

  static TaskCategory fromMap(Map<String, dynamic> map) {
    return TaskCategory(
      name: map['name'],
      value: map['value'],
      id: map['id'],
    );
  }
}
