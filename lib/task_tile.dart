import 'package:flutter/material.dart';
import 'package:timescape/item_manager.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class TaskTile extends StatefulWidget {
  final Item item;
  const TaskTile({Key? key, required this.item}) : super(key: key);

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
        child: InkWell(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isExpanded ? 230 : 0,
                width: screenWidth * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromRGBO(0, 39, 41, 1),
                    width: 2.0,
                  ),
                  color: const Color.fromRGBO(214, 253, 255, 1),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(0, 58, 61, 1),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            "Deadline: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.item.deadline)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(0, 58, 61, 1),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            "Estimated Length: ${widget.item.estimatedLength.toString().split('.').first.padLeft(8, "0")}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(0, 58, 61, 1),
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            "Urgency: ${widget.item.urgency}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color.fromRGBO(0, 58, 61, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Slidable(
                startActionPane: ActionPane(
                  // A motion is a widget used to control how the pane animates.
                  motion: const BehindMotion(),

                  // A pane can dismiss the Slidable.
                  dismissible: DismissiblePane(onDismissed: () {}),

                  // All actions are defined in the children parameter.
                  children: [
                    // A SlidableAction can have an icon and/or a label.
                    SlidableAction(
                      onPressed: (BuildContext context) {},
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) {},
                      backgroundColor: Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'Share',
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 39, 41, 1),
                        width: 2.0,
                      ),
                      color: const Color.fromRGBO(0, 78, 82, 1),
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
            ],
          ),
        ),
      ),
    );
  }
}
