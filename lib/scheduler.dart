import 'dart:collection';

import 'package:timescape/database_helper.dart';
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

List<Assignment> scheduler(EntryManager itemManager, List<TimeBlock> timeBlocks,
    int breakTime, List<Event> events) {
  List<String> prioritisedItemIDs = itemManager
      .classifyTasksIntoQuadrants()
      .fold([], (previousValue, element) => previousValue + element);

  timeBlocks.forEach((element) {
    print("Timeblock Time - ${element.time} - Duration - ${element.duration}");
  });
  for (String itemID in prioritisedItemIDs) {
    Task item = itemManager.entries[itemID]! as Task;
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

int timeAvailable(Duration unassignedDuration, Duration unallocatedTime) {
  if (unassignedDuration <= unallocatedTime) {
    return 0;
  } else if (unassignedDuration >= unallocatedTime) {
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
