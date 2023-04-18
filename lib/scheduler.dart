import 'dart:collection';

import 'package:timescape/item_manager.dart';

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

List<TimeBlock> scheduler(UnmodifiableMapView<String, Item> items,
    List<TimeBlock> timeBlocks, int breakTime) {
  for (String itemID in items.keys.toList()) {
    Item item = items[itemID]!;
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
