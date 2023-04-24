import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/entry_form.dart';
import 'package:timescape/task_tile.dart';
import 'dart:math';

import 'entry_manager.dart';

class EntryListView extends StatelessWidget {
  final EntryType entryType;
  const EntryListView({super.key, required this.entryType});

  TaskTileColors getTileColors(EntryType type) {
    switch (type) {
      case EntryType.reminder:
        return const TaskTileColors(
          tileColor: Color.fromRGBO(11, 213, 156, 1),
          tileBorderColor: Color.fromRGBO(10, 176, 130, 1),
          innerTileColor: Color.fromRGBO(75, 225, 183, 1),
          innerTileFontColor: Colors.white,
        );
      case EntryType.event:
        return const TaskTileColors(
          tileColor: Color.fromRGBO(50, 162, 176, 1),
          tileBorderColor: Color.fromRGBO(61, 199, 217, 1),
          innerTileColor: Color.fromRGBO(107, 206, 218, 1),
          innerTileFontColor: Colors.white,
        );
      default: // For task type
        return const TaskTileColors(
          tileColor: Color.fromRGBO(0, 78, 82, 1),
          tileBorderColor: Color.fromRGBO(0, 39, 41, 1),
          innerTileColor: Color.fromRGBO(214, 253, 255, 1),
          innerTileFontColor: Color.fromRGBO(0, 58, 61, 1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryManager>(
      builder: (context, itemManager, child) {
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
        final colors = getTileColors(entryType);
        return Stack(
          children: [
            ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return TaskTile(
                    key: Key(itemKeys[index]), item: item, colors: colors);
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
