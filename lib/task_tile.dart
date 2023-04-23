import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/item_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

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
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Text(
                              "Description: ${widget.item.description}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: widget.colors.innerTileFontColor,
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            if (widget.item.type == EntryType.task)
                              Text(
                                "Deadline: ${DateFormat('yyyy-MM-dd HH:mm:ss').format((widget.item as Task).deadline)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.colors.innerTileFontColor,
                                ),
                              ),
                            if (widget.item.type == EntryType.task)
                              const Divider(
                                thickness: 1,
                              ),
                            if (widget.item.type == EntryType.task)
                              Text(
                                "Estimated Length: ${(widget.item as Task).estimatedLength.toString().split('.').first.padLeft(8, "0")}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.colors.innerTileFontColor,
                                ),
                              ),
                            if (widget.item.type == EntryType.task)
                              const Divider(
                                thickness: 1,
                              ),
                            if (widget.item.type == EntryType.task)
                              Text(
                                "N Weight Urgency: ${(widget.item as Task).urgency}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: widget.colors.innerTileFontColor,
                                ),
                              ),
                          ],
                        ),
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
                        await DatabaseHelper()
                            .deleteTask((widget.item as Task));
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) {},
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Edit',
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
                        widget.item.title,
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
}
