import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/date_picker.dart';
import 'package:timescape/duration_picker.dart';
import 'package:timescape/task_tile.dart';
import 'package:timescape/toggle_selection.dart';
import 'dart:math';

import 'item_manager.dart';

class EntryListView extends StatelessWidget {
  final EntryType entryType;
  const EntryListView({super.key, required this.entryType});
  @override
  Widget build(BuildContext context) {
    return Consumer<EntryManager>(
      builder: (context, itemManager, child) {
        // Use yourProvider data to build your widget tree here
        final items = itemManager.entries.values
            .where((entry) => entry.type == entryType)
            .toList()
            .reversed
            .toList();
        final itemKeys = itemManager.entries.keys
            .where((key) => itemManager.entries[key]!.type == entryType)
            .toList()
            .reversed
            .toList();
        return Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                print("Keys: ${itemKeys[index]}");
                return TaskTile(
                  key: Key(itemKeys[index]),
                  item: item,
                );
              },
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color.fromRGBO(0, 39, 41, 1),
                onPressed: () {
                  String itemTitle = '';
                  String itemDescription = '';
                  DateTime deadline = DateTime.now();
                  Duration duration = const Duration(hours: 0, minutes: 15);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      final double bottomPadding = max(
                        MediaQuery.of(context).viewInsets.bottom,
                        MediaQuery.of(context).size.height *
                            0.05, // Add a minimum padding of 5% of the screen height
                      );
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: bottomPadding),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter task name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    itemTitle = value;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter task description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    itemDescription = value;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ToggleButtonSelection(
                                  onPressCallback: (selected) {
                                    _selected = selected;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DateTimePicker(
                                  onDateTimeChanged: (DateTime newDate) {
                                    deadline = newDate;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: DurationPicker(
                                  initialDuration: duration,
                                  onDurationChanged: (Duration newDuration) {
                                    duration = newDuration;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Task item = Task(
                                      title: itemTitle,
                                      description: itemDescription,
                                      deadline: deadline,
                                      estimatedLength: duration,
                                    );
                                    Provider.of<EntryManager>(context,
                                            listen: false)
                                        .addEntry(item);
                                    Navigator.pop(context);
                                    await DatabaseHelper().addTask(item);
                                  },
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
