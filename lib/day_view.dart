import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timescape/scheduler.dart';

class DayView extends StatefulWidget {
  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  final ScrollController scrollController = ScrollController();
  double overlayPosition = 0;
  List<Assignment> assignments = [];

  @override
  void initState() {
    super.initState();
    scrollController.addListener(handleScroll);
    loadData();
  }

  void loadData() async {
    final itemManager = Provider.of<EntryManager>(context, listen: false);
    final eventsToday = await itemManager.getEventsToday();
    final freeTimeBlocks = await itemManager.getFreeTimeBlocksToday();
    setState(() {
      assignments = scheduler(itemManager, freeTimeBlocks, 10, eventsToday);
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(handleScroll);
    super.dispose();
  }

  void handleScroll() {
    setState(() {
      overlayPosition = -scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    // var assignments = [
    //   Assignment(
    //     time: DateTime(2023, 4, 18, 8, 40),
    //     itemID: '84965dc0-53b7-444d-84f2-2f3437e6761f',
    //     duration: const Duration(minutes: 120),
    //   ),
    //   Assignment(
    //     time: DateTime(2023, 4, 18, 14, 0),
    //     itemID: '1c7b6b5d-eb06-479d-8009-5316851c13e8',
    //     duration: const Duration(minutes: 60),
    //   ),
    // ];

    return Consumer<EntryManager>(builder: (context, itemManager, child) {
      return RefreshIndicator(
        onRefresh: () async {
          print("Refreshed");
          final List<Event> eventsToday = await itemManager.getEventsToday();
          List<TimeBlock> freeTimeBlocks =
              await itemManager.getFreeTimeBlocksToday();
          setState(() {
            assignments =
                scheduler(itemManager, freeTimeBlocks, 5, eventsToday);
          });
        },
        child: Stack(
          children: [
            ListView.builder(
              controller: scrollController,
              itemCount: 96,
              itemBuilder: (context, index) {
                int hour = index ~/ 4;
                int minute = (index % 4) * 15;
                String time = "    ";

                double thickness = 1;
                Color dividerColor = Colors.grey;
                if (index % 4 == 0) {
                  time =
                      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                  thickness = 3;
                  dividerColor = Colors.black;
                }

                return Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: SizedBox(
                          height: 25,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 55,
                                child: Text(
                                  time,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Divider(
                                  thickness: thickness,
                                  color: dividerColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ...assignments.map((assignment) {
              double top =
                  (assignment.time.hour * 60 + assignment.time.minute) /
                          15 *
                          25 +
                      12.5;

              Entry entry = itemManager.entries[assignment.itemID]!;
              // print(
              // "${entry.title} - Duration - ${assignment.duration} - Time - ${assignment.time}");
              double height = assignment.duration.inMinutes / 15 * 25;

              final color = entry.type == EntryType.task
                  ? const Color.fromRGBO(214, 253, 255, 1)
                  : const Color.fromRGBO(107, 206, 218, 1);

              final borderColor = entry.type == EntryType.task
                  ? const Color.fromRGBO(0, 39, 41, 1)
                  : const Color.fromARGB(255, 39, 136, 148);

              final fontColor = entry.type == EntryType.task
                  ? const Color.fromARGB(255, 0, 102, 107)
                  : const Color.fromARGB(255, 6, 35, 39);

              return Positioned(
                top: overlayPosition + top,
                left: 80,
                width: 300,
                height: height,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: color,
                        title: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            entry.title,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: fontColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        content: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            "Time: ${DateFormat('HH:mm').format(assignment.time)}\nDuration: ${assignment.duration.toString().split('.').first.padLeft(6, "0")}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: fontColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              "OK",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: fontColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                          color: borderColor,
                          strokeAlign: BorderSide.strokeAlignInside),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        entry.title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: fontColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList()
          ],
        ),
      );
    });
  }
}
