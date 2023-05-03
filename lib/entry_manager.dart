import 'dart:collection';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timescape/database_helper.dart';
import 'package:uuid/uuid.dart';

const timeLeeway = Duration(days: 3);

class EntryManager extends ChangeNotifier {
  TimeOfDay startWorkTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endWorkTime = const TimeOfDay(hour: 17, minute: 0);
  final Map<String, Entry> _entries = {};
  final List<TaskCategory> categories = [];
  UnmodifiableMapView<String, Entry> get entries =>
      UnmodifiableMapView<String, Entry>(_entries);

  EntryManager({Key? key});

  void generateEntrys() {
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

        TaskCategory category = categories[i];
        DateTime deadline = DateTime.now().add(Duration(days: days));
        addEntry(Task(
          id: '',
          title: 'Entry ${category.value}-$estimatedLength-$days',
          description: 'Description for item ${category.value}-${j + 1}',
          isCompleted: false,
          deadline: deadline,
          estimatedLength: Duration(minutes: estimatedLength),
          categoryID: category.id,
        ));
      }
    }
  }

  double minMaxNormalization(double value, double min, double max) {
    return (value - min) / (max - min);
  }

  double euclideanDistance(List<double> pointA, List<double> pointB) {
    double sum = 0;
    for (int i = 0; i <= pointA.length - 1; i++) {
      sum += pow(pointA[i] - pointB[i], 2);
    }
    return sqrt(sum);
  }

  double lengthToDeadlineRatio(Task task) {
    int timeTillDeadline =
        task.deadline.difference(DateTime.now()).inMinutes > 0
            ? task.deadline.difference(DateTime.now()).inMinutes
            : 1;
    return task.estimatedLength.inMinutes / timeTillDeadline;
  }

  /* 
    Group tasks into the 4 quadrants of the Eisenhower matrix using 25th and 75th
    percentile values of the normalized length to deadline ratio and normalized 
    importance of all tasks. 
  */
  List<List<String>> classifyTasksIntoQuadrants() {
    List<Task> taskList = _entries.values.whereType<Task>().toList();

    // Do not try to sort into quadrants without enough data points, instead sort by length to deadline ratio
    if (taskList.length < 10) {
      taskList.sort((a, b) =>
          lengthToDeadlineRatio(a).compareTo(lengthToDeadlineRatio(b)));
      return [taskList.map((item) => item.id).toList(), [], [], []];
    }

    List<List<String>> eisenhowerQuadrants = [
      [], // Urgent & Important
      [], // Not Urgent & Important
      [], // Urgent & Not Important
      [], // Not Urgent & Not Important
    ];

    // Calculate max importance value to allow for min-max normalization
    List<double> importanceVals = taskList
        .map((e) => categories
            .firstWhere((category) => e.categoryID == category.id)
            .value
            .toDouble())
        .toList();

    double maxImportance = importanceVals.fold(
        0, (prev, current) => current > prev ? current : prev);

    // Generate normalized feature values for each task, and enter into map
    Map<String, List<double>> itemFeatures = {};
    for (Task item in taskList) {
      int timeTillDeadline =
          item.deadline.difference(DateTime.now()).inMinutes > 0
              ? item.deadline.difference(DateTime.now()).inMinutes
              : 1;
      double lengthToDeadlineRatio =
          item.estimatedLength.inMinutes / timeTillDeadline;
      double normalizedImportance = minMaxNormalization(
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

    // Calculate feature percentiles
    List<List<double>> itemFeatureList = itemFeatures.values.toList();

    itemFeatureList.sort((a, b) => a[0].compareTo(b[0]));
    double lengthToDeadlineRatioP25 =
        itemFeatureList[(itemFeatureList.length * 0.25).floor()][0];
    double lengthToDeadlineRatioP75 =
        itemFeatureList[(itemFeatureList.length * 0.75).floor()][0];

    itemFeatureList.sort((a, b) => a[1].compareTo(b[1]));
    double importanceP25 =
        itemFeatureList[(itemFeatureList.length * 0.25).floor()][1];
    double importanceP75 =
        itemFeatureList[(itemFeatureList.length * 0.75).floor()][1];

    // print("ImportanceP25 ${importanceP25} ImportanceP75 ${importanceP75}");

    // Define "shadow" centroids
    List<List<double>> centroids = [
      [lengthToDeadlineRatioP75, importanceP75], // Urgent & Important
      [lengthToDeadlineRatioP25, importanceP75], // Not Urgent & Important
      [lengthToDeadlineRatioP75, importanceP25], // Urgent & Not Important
      [lengthToDeadlineRatioP25, importanceP25], // Not Urgent & Not Important
    ];

    // Classify items into quadrants by calculating closest "shadow" centroid to task based on features
    List<String> itemIds = itemFeatures.keys.toList();
    for (String itemId in itemIds) {
      List<double> itemCoordinates = itemFeatures[itemId]!;
      double minDistance = double.infinity;
      int minIndex = 0;

      for (int i = 0; i < centroids.length; i++) {
        double distance = euclideanDistance(itemCoordinates, centroids[i]);
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

      // Assign task to approriate quadrant
      eisenhowerQuadrants[minIndex].add(itemId);
    }

    // Sort each quadrant by
    for (List<String> quadrant in eisenhowerQuadrants) {
      quadrant.sort((a, b) {
        final taskA = entries[a] as Task;
        final taskB = entries[b] as Task;
        return lengthToDeadlineRatio(taskB)
            .compareTo(lengthToDeadlineRatio(taskA));
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

  // Persistence for work hour preferences
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

  // Load data into manager from persistence layer
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

    final retrievedCategories = await DatabaseHelper().getCategories();

    for (final category in retrievedCategories) {
      categories.add(category);
    }

    // generateEntrys();
    // generateEntrys();
    // generateEntrys(5);
    // generateEntrys(8);

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

  void removeAll() {
    _entries.clear();
    notifyListeners();
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

  Future<List<TimeBlock>> getFreeTimeBlocksToday() async {
    final List<Event> eventsToday = await getEventsToday();
    final List<TimeBlock> timeBlocks = [];

    DateTime workStartTime =
        DateTime(1, 1, 1, startWorkTime.hour, startWorkTime.minute);
    DateTime workEndTime =
        DateTime(1, 1, 1, endWorkTime.hour, endWorkTime.minute);

    print("Start Time ${workStartTime}");
    print("End Time ${workEndTime}");

    // Sort events by start time
    eventsToday.sort((a, b) => DateTime(
            1, 1, 1, a.startTime.hour, a.startTime.minute)
        .compareTo(DateTime(1, 1, 1, b.startTime.hour, b.startTime.minute)));

    if (eventsToday.isNotEmpty) {
      print("Break1");
      Event firstEvent = eventsToday.first;
      DateTime eventStartTime = DateTime(
          1, 1, 1, firstEvent.startTime.hour, firstEvent.startTime.minute);
      if (eventStartTime.isAfter(workStartTime)) {
        print("Break2");
        timeBlocks.add(TimeBlock(
            time: workStartTime,
            duration: eventStartTime.difference(workStartTime)));
      }
    } else {
      print("Break3");
      timeBlocks.add(TimeBlock(
          time: workStartTime,
          duration: workEndTime.difference(workStartTime)));
    }

    // Iterate through event list to check free time between events
    for (int i = 0; i < eventsToday.length; i++) {
      print("Break1");

      Event currentEvent = eventsToday[i];
      DateTime currentEventStartTime = DateTime(
          1, 1, 1, currentEvent.startTime.hour, currentEvent.startTime.minute);
      DateTime currentEventEndTime =
          currentEventStartTime.add(currentEvent.length);

      if (currentEventEndTime.isAfter(DateTime(1, 1, 1, 24))) {
        currentEventEndTime = DateTime(1, 1, 1, 24);
      }

      print("Break2");
      // Check if time between the current event and next (or end of day, whichever is closer)
      if (i < eventsToday.length - 1) {
        Event nextEvent = eventsToday[i + 1];
        DateTime nextEventStartTime = DateTime(
            1, 1, 1, nextEvent.startTime.hour, nextEvent.startTime.minute);
        if (nextEventStartTime.isAfter(currentEventEndTime)) {
          if (nextEventStartTime.isBefore(workEndTime)) {
            if (currentEventEndTime.isBefore(workStartTime)) {
              timeBlocks.add(TimeBlock(
                  time: workStartTime,
                  duration: nextEventStartTime.difference(workStartTime)));
            } else {
              timeBlocks.add(TimeBlock(
                  time: currentEventEndTime,
                  duration:
                      nextEventStartTime.difference(currentEventEndTime)));
            }
          } else {
            timeBlocks.add(TimeBlock(
                time: currentEventEndTime,
                duration: workEndTime.difference(currentEventEndTime)));
          }
        }
      } else if (currentEventEndTime.isBefore(workEndTime)) {
        if (currentEventEndTime.isBefore(workStartTime)) {
          timeBlocks.add(TimeBlock(
              time: workStartTime,
              duration: workEndTime.difference(workStartTime)));
        } else {
          timeBlocks.add(TimeBlock(
              time: currentEventEndTime,
              duration: workEndTime.difference(currentEventEndTime)));
        }
      }
    }

    return timeBlocks;
  }

  int timeAvailable(Duration unassignedDuration, Duration unallocatedTime) {
    if (unassignedDuration <= unallocatedTime) {
      return 0;
    } else if (unassignedDuration >= unallocatedTime) {
      return 1;
    } else {
      return -1;
    }
  }

  Future<List<Assignment>> scheduler(int breakTime) async {
    List<Event> events = await getEventsToday();
    List<TimeBlock> timeBlocks = await getFreeTimeBlocksToday();
    List<String> prioritisedItemIDs = classifyTasksIntoQuadrants()
        .fold([], (previousValue, element) => previousValue + element);

    timeBlocks.forEach((element) {
      print(
          "Timeblock Time - ${element.time} - Duration - ${element.duration}");
    });
    for (String itemID in prioritisedItemIDs) {
      Task item = entries[itemID]! as Task;
      Duration unassignedDuration =
          (item.estimatedLength - item.timeSpent).inMinutes < 0
              ? Duration.zero
              : (item.estimatedLength - item.timeSpent);
      for (TimeBlock block in timeBlocks) {
        Duration allocatedTime = block.assignments.fold(
          Duration.zero,
          (previousValue, element) =>
              previousValue + element.duration + Duration(minutes: breakTime),
        );

        Duration unallocTime = block.duration - allocatedTime;
        int availability = timeAvailable(unassignedDuration, unallocTime);
        if (availability == 0) {
          block.assignments.add(Assignment(
            time: block.time.add(allocatedTime),
            itemID: itemID,
            duration: unassignedDuration,
          ));
          unassignedDuration = Duration.zero;
        } else if (availability == 1) {
          block.assignments.add(Assignment(
            time: block.time.add(allocatedTime),
            itemID: itemID,
            duration: unallocTime,
          ));
          unassignedDuration -= unallocTime;
          block.duration -= const Duration(minutes: 30);
        }

        if (unassignedDuration.inMinutes == 0) {
          break;
        }
      }
    }

    List<Assignment> assignments = timeBlocks.fold<List<Assignment>>(
      [],
      (acc, timeBlock) {
        return acc + timeBlock.assignments;
      },
    );
    assignments += events
        .map(
          (e) => Assignment(
              time: DateTime(1, 1, 1, e.startTime.hour, e.startTime.minute),
              itemID: e.id,
              duration: e.length),
        )
        .toList();

    return assignments;
  }
}

// Used for identification of Entry type across application for conditional rendering
enum EntryType {
  task,
  reminder,
  event,
}

// Super class to represent all entries within app
// Each sub class has toMap and fromMap functions for easy addition/deletion from db
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
    // Generate UUID for easy unique identification, and assigning keys to TaskTile components
    if (id == '' || id == null) {
      this.id = const Uuid().v4();
    } else {
      this.id = id;
    }
  }
}

class Task extends Entry {
  bool isCompleted;
  DateTime deadline;
  Duration timeSpent = const Duration();
  Duration estimatedLength;

  // Used to calculate features for quadrant sorting
  int categoryID = 0;

  Task({
    String? id,
    required String title,
    required String description,
    required this.deadline,
    required this.estimatedLength,
    this.isCompleted = false,
    this.timeSpent = Duration.zero,
    required this.categoryID,
  }) : super(
          id: id,
          title: title,
          description: description,
          type: EntryType.task,
        );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted ? 1 : 0,
      'deadline': deadline.millisecondsSinceEpoch,
      'time_spent': timeSpent.inMilliseconds,
      'estimated_length': estimatedLength.inMilliseconds,
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
      categoryID: map['category'],
      id: map['id'],
    );
  }

  void editCompleted(bool isCompleted) {
    this.isCompleted = isCompleted;
  }

  void editDeadline(DateTime deadline) {
    this.deadline = deadline;
  }

  void editEstimatedLength(Duration estimatedLength) {
    this.estimatedLength = estimatedLength;
  }

  void incrementTimeSpent() {
    timeSpent = Duration(seconds: timeSpent.inSeconds + 1);
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

  Event({
    String? id,
    required String title,
    required String description,
    required this.startDate,
    required this.startTime,
    required this.length,
    required this.recurrence,
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

    List<int> startTimeParams = ((map['startTime'] as String).split(','))
        .map((e) => int.parse(e))
        .toList();

    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime:
          TimeOfDay(hour: startTimeParams[0], minute: startTimeParams[1]),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
      length: Duration(minutes: map['length']),
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

class Assignment {
  DateTime time;
  Duration duration;
  String itemID;

  Assignment({
    required this.time,
    required this.itemID,
    required this.duration,
  });
}

class TimeBlock {
  final DateTime time;
  Duration duration;
  List<Assignment> assignments;

  TimeBlock({required this.time, required this.duration})
      : assignments = List.empty(growable: true);
}
