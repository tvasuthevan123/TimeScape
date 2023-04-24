import 'dart:collection';

import 'package:timescape/entry_manager.dart';

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

List<TimeBlock> scheduler(UnmodifiableMapView<String, Task> items,
    List<TimeBlock> timeBlocks, int breakTime) {
  for (String itemID in items.keys.toList()) {
    Task item = items[itemID]!;
    Duration unassignedDuration = item.estimatedLength;
    for (TimeBlock block in timeBlocks) {
      int availability = timeAvailable(unassignedDuration, block);
      if (availability == 0) {
        block.assignments.add(Assignment(
          time: block.time.add(unassignedDuration),
          itemID: itemID,
          duration: unassignedDuration,
        ));
        unassignedDuration = Duration.zero;
      } else if (availability == 1) {
        block.assignments.add(Assignment(
          time: block.time.add(unassignedDuration),
          itemID: itemID,
          duration: const Duration(minutes: 30),
        ));
        unassignedDuration -= const Duration(minutes: 30);
        block.duration -= const Duration(minutes: 30);
      }

      if (unassignedDuration.inMinutes == 0) {
        break;
      }
    }

    if (unassignedDuration > Duration.zero &&
        item.urgency >= 0.8 &&
        item.isSoftDeadline == false) {
      warning();
    }
  }

  return timeBlocks;
}

int timeAvailable(Duration unassignedDuration, TimeBlock block) {
  Duration time = block.duration;
  if (unassignedDuration <= time) {
    return 0;
  } else if (unassignedDuration >= const Duration(minutes: 30) &&
      time >= const Duration(minutes: 30)) {
    return 1;
  } else {
    return -1;
  }
}

void warning() {
  print('Warning: Task may not be completed before hard deadline.');
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
