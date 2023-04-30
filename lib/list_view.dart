import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/task_tile.dart';

import 'entry_manager.dart';

class EntryListView extends StatelessWidget {
  final EntryType entryType;
  const EntryListView({super.key, required this.entryType});

  TaskTileColors getTileColors(Entry entry) {
    switch (entry.type) {
      case EntryType.reminder:
        return const TaskTileColors(
          tileColor: Color.fromRGBO(8, 135, 99, 1),
          tileBorderColor: Color.fromRGBO(0, 44, 32, 1),
          innerTileColor: Color.fromRGBO(75, 225, 183, 1),
          innerTileFontColor: Color.fromRGBO(3, 26, 19, 1),
        );
      case EntryType.event:
        return const TaskTileColors(
          tileColor: Color.fromRGBO(50, 162, 176, 1),
          tileBorderColor: Color.fromRGBO(19, 68, 75, 1),
          innerTileColor: Color.fromRGBO(172, 242, 248, 1),
          innerTileFontColor: Color.fromRGBO(19, 75, 83, 1),
        );
      default: // For task type
        if ((entry as Task).deadline.difference(DateTime.now()).inMilliseconds <
            0) {
          return const TaskTileColors(
            tileColor: Color.fromRGBO(220, 53, 69, 1), // red
            tileBorderColor: Color.fromRGBO(123, 32, 47, 1), // dark red
            innerTileColor: Color.fromRGBO(255, 204, 204, 1), // light red
            innerTileFontColor: Color.fromRGBO(123, 32, 47, 1), // dark red
          );
        }
        return const TaskTileColors(
          tileColor: Color.fromRGBO(0, 78, 82, 1),
          tileBorderColor: Color.fromRGBO(0, 39, 41, 1),
          innerTileColor: Color.fromRGBO(214, 253, 255, 1),
          innerTileFontColor: Color.fromRGBO(0, 58, 61, 1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryManager>(
      builder: (context, itemManager, child) {
        final items = itemManager.entries.values
            .where((entry) => entry.type == entryType)
            .toList();

        items.sort((a, b) {
          switch (a.type) {
            case EntryType.task:
              return (a as Task).deadline.compareTo((b as Task).deadline);
            case EntryType.reminder:
              return (a as Reminder)
                  .dateTime
                  .compareTo((b as Reminder).dateTime);
            case EntryType.event:
              return -1;
          }
        });
        return Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return TaskTile(
                    key: Key(item.id), item: item, colors: getTileColors(item));
              },
            ),
          ],
        );
      },
    );
  }
}
