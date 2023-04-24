import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/date_picker.dart';
import 'package:timescape/duration_picker.dart';
import 'package:timescape/entry_form.dart';
import 'package:timescape/task_tile.dart';
import 'package:timescape/toggle_selection.dart';
import 'dart:math';

import 'entry_manager.dart';

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
                  EntryType entryType = EntryType.task;
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
                          child: EntryForm(),
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
