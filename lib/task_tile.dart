import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/entry_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:timescape/focus_mode.dart';

class TaskTileColors {
  final Color tileColor;
  final Color tileBorderColor;
  final Color innerTileColor;
  final Color innerTileFontColor;

  const TaskTileColors({
    required this.tileColor,
    required this.tileBorderColor,
    required this.innerTileColor,
    required this.innerTileFontColor,
  });
}

class TaskTile extends StatefulWidget {
  final Entry item;
  final TaskTileColors colors;

  const TaskTile({
    Key? key,
    required this.item,
    this.colors = const TaskTileColors(
      tileColor: Color.fromRGBO(0, 78, 82, 1),
      tileBorderColor: Color.fromRGBO(0, 39, 41, 1),
      innerTileColor: Color.fromRGBO(214, 253, 255, 1),
      innerTileFontColor: Color.fromRGBO(0, 58, 61, 1),
    ),
  }) : super(key: key);

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<EntryManager>(builder: (context, entryManager, child) {
      List<String> info = taskInfo(entryManager, widget.item as Task);
      if (widget.item.type == EntryType.reminder) {
        info = reminderInfo(widget.item as Reminder);
      }
      if (widget.item.type == EntryType.event) {
        info = eventInfo(widget.item as Event);
      }
      Widget infoWidget = entryInfoWidget(info);
      return Padding(
        padding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          onLongPress: () {
            // placeholder code for "on press and hold"
          },
          child: Stack(
            children: [
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isExpanded ? 230 : 0,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: widget.colors.tileBorderColor,
                      width: 2.0,
                    ),
                    color: widget.colors.innerTileColor,
                  ),
                  child: ClipRect(
                    child: OverflowBox(
                      maxHeight: _isExpanded ? 230 : 0,
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                        child: infoWidget,
                      ),
                    ),
                  ),
                ),
              ),
              Slidable(
                startActionPane: ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const BehindMotion(),
                  // All actions are defined in the children parameter.
                  children: [
                    // A SlidableAction can have an icon and/or a label.
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        entryManager.removeEntry(widget.item.id);
                        await DatabaseHelper().deleteEntry(widget.item);
                      },
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    if (widget.item.type == EntryType.task)
                      SlidableAction(
                        onPressed: (BuildContext context) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (_) =>
                                    FocusMode(task: widget.item as Task)),
                          );
                        },
                        backgroundColor: const Color.fromARGB(255, 45, 198, 83),
                        foregroundColor: Colors.white,
                        icon: Icons.play_arrow,
                        label: 'Focus',
                      ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: widget.colors.tileBorderColor,
                          width: 2.0,
                        ),
                        color: widget.colors.tileColor,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "${widget.item.title} - ${info[info.length - 1]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget entryInfoWidget(List<String> info) {
    return Column(
        children: info.fold(
      [],
      (previousValue, element) =>
          previousValue +
          [
            Text(
              element,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.colors.innerTileFontColor,
              ),
            ),
            const Divider(
              thickness: 1,
            ),
          ],
    ));
  }

  List<String> eventInfo(Event event) {
    return [
      if (event.description.isNotEmpty) "Description: ${event.description}",
      "Date: ${DateFormat('yyyy-MM-dd HH:mm').format(event.startDate)}",
      "Duration: ${event.length.toString().split('.').first.padLeft(8, "0")}",
      DateFormat('yyyy-MM-dd').format(event.startDate),
    ];
  }

  List<String> taskInfo(EntryManager entryManager, Task task) {
    print(task.categoryID);
    TaskCategory category = entryManager.categories
        .firstWhere((element) => element.id == task.categoryID);

    print(task.categoryID);
    print(entryManager.categories
        .where((element) => element.id == task.categoryID));
    return [
      if (task.description.isNotEmpty) "Description: ${task.description}",
      "Category: ${category.name}  Importance: ${category.value}",
      "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(task.deadline)}",
      "Estimated Length: ${task.estimatedLength.toString().split('.').first.padLeft(8, "0")}",
      DateFormat('yyyy-MM-dd').format(task.deadline),
    ];
  }

  List<String> reminderInfo(Reminder reminder) {
    return [
      if (reminder.description.isNotEmpty)
        "Description: ${reminder.description}",
      "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(reminder.dateTime)}",
      DateFormat('yyyy-MM-dd').format(reminder.dateTime),
    ];
  }
}
