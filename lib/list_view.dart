import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/date_picker.dart';
import 'package:timescape/duration_picker.dart';
import 'package:timescape/task_tile.dart';
import 'package:timescape/toggle_selection.dart';

import 'item_manager.dart';

class ItemListView extends StatelessWidget {
  final ItemType type;
  const ItemListView({super.key, required this.type});
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemManager>(
      builder: (context, itemManager, child) {
        // Use yourProvider data to build your widget tree here
        final items = itemManager.items.values.toList().reversed.toList();
        final itemKeys = itemManager.items.keys.toList().reversed.toList();
        return Stack(
          children: [
            ListView.builder(
              itemCount: itemManager.items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                print("Keys: ${itemKeys[index]}");
                if (item.type == type) {
                  return Center(
                    child: TaskTile(
                      key: Key(itemKeys[index]),
                      item: item,
                    ),
                  );
                }
                return null;
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
                  ItemType itemType = ItemType.task;
                  DateTime deadline = DateTime.now();
                  Duration duration = const Duration(hours: 0, minutes: 15);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
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
                                    if (selected == 0) {
                                      itemType = ItemType.task;
                                    } else {
                                      itemType = ItemType.reminder;
                                    }
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
                                  onPressed: () {
                                    Item item = Item(
                                      title: itemTitle,
                                      description: itemDescription,
                                      type: itemType,
                                      deadline: deadline,
                                      estimatedLength: duration,
                                    );
                                    Provider.of<ItemManager>(context,
                                            listen: false)
                                        .addItem(item);
                                    Navigator.pop(context);
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
