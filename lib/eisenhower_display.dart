import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timescape/task_tile.dart';

class EisenhowerMatrix extends StatelessWidget {
  static List<String> quadrantNames = [
    'Urgent & Important',
    'Not Urgent & Important',
    'Urgent & Not Important',
    'Not Urgent & Not Important'
  ];

  const EisenhowerMatrix({super.key});

  Widget buildTaskTile(BuildContext context, Task item, TaskTileColors colors) {
    return TaskTile(item: item, colors: colors);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryManager>(builder: (context, itemManager, child) {
      List<List<String>> classifiedTasks = itemManager.classifyTasksIntoQuadrants();
      List<List<String>> allTasks = [];

      for (int i = 0; i < classifiedTasks.length; i++) {
        List<String> quadrantTasks = classifiedTasks[i];
        for (int j = 0; j < quadrantTasks.length; j++) {
          String itemId = quadrantTasks[j];
          String quadrantName = quadrantNames[i];
          String colorCode = '';

          switch (i) {
            case 0:
              colorCode = 'UrgentImportant';
              break;
            case 1:
              colorCode = 'NotUrgentImportant';
              break;
            case 2:
              colorCode = 'UrgentNotImportant';
              break;
            case 3:
              colorCode = 'NotUrgentNotImportant';
              break;
          }

          allTasks.add([itemId, quadrantName, colorCode]);
        }
      }

      return ListView.builder(
        itemCount: allTasks.length,
        itemBuilder: (BuildContext context, int index) {
          String itemId = allTasks[index][0];
          String colorCode = allTasks[index][2];
          TaskTileColors color = TaskTileColors(
            tileColor: Colors.purple.shade900,
            tileBorderColor: Colors.purple.shade800,
            innerTileColor: Colors.purple.shade100,
            innerTileFontColor: Colors.purple.shade900,
          );

          switch (colorCode) {
            case 'NotUrgentImportant':
              color = TaskTileColors(
                tileColor: Colors.green.shade900,
                tileBorderColor: Colors.green.shade800,
                innerTileColor: Colors.green.shade100,
                innerTileFontColor: Colors.green.shade900,
              );
              break;
            case 'UrgentNotImportant':
              color = const TaskTileColors(
                tileColor: Color.fromARGB(255, 50, 11, 30),
                tileBorderColor: Color.fromARGB(255, 49, 5, 27),
                innerTileColor: Color.fromARGB(255, 133, 78, 104),
                innerTileFontColor: Color.fromARGB(255, 12, 1, 6),
              );
              break;
            case 'NotUrgentNotImportant':
              color = TaskTileColors(
                tileColor: Colors.blue.shade900,
                tileBorderColor: Colors.blue.shade800,
                innerTileColor: Colors.blue.shade100,
                innerTileFontColor: Colors.blue.shade900,
              );
              break;
          }

          return buildTaskTile(
            context,
            itemManager.entries[itemId] as Task,
            color,
          );
        },
      );
    });
  }
}
