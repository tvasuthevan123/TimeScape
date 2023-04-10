import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/toggle_selection.dart';

import 'item_manager.dart';

class ItemListView extends StatelessWidget {
  const ItemListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemManager>(
      builder: (context, itemManager, child) {
        // Use yourProvider data to build your widget tree here
        return Stack(
          children: [
            ListView.builder(
              itemCount: itemManager.items.length,
              itemBuilder: (context, index) {
                final items =
                    itemManager.items.values.toList().reversed.toList();
                return ListTile(
                  title: Text(items[index].title),
                );
              },
            ),
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  String itemTitle = '';
                  String itemDescription = '';
                  ItemType itemType = ItemType.task;
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
                                child: ElevatedButton(
                                  onPressed: () {
                                    Item item = Item(
                                      title: itemTitle,
                                      description: itemDescription,
                                      itemType: itemType,
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
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }
}
