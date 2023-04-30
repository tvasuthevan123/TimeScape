import 'package:flutter/material.dart';
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
  final ScrollController _scrollController = ScrollController();
  double _overlayPosition = 0;
  List<Assignment> assignments = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    setState(() {
      _overlayPosition = -_scrollController.offset;
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
          List<Event> eventsToday = await itemManager.getEventsToday();
          List<TimeBlock> freeTimeBlocks =
              await itemManager.getFreeTimeBlocksToday(eventsToday);
          setState(() {
            assignments =
                scheduler(itemManager, freeTimeBlocks, 5, eventsToday);
          });
        },
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
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
              return Positioned(
                  top: _overlayPosition + top,
                  left: 80,
                  width: 250,
                  height: height,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      color: Colors.lightBlue,
                      alignment: Alignment.topLeft,
                      child: Text(
                        entry.title,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ));
            }).toList()
          ],
        ),
      );
    });
  }
}
