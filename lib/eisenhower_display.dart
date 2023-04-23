import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/item_manager.dart';
import 'package:timescape/task_tile.dart';

class EisenhowerMatrix extends StatelessWidget {
  Widget _buildQuadrantListView(
      BuildContext context, List<String> quadrantItemIds) {
    return ListView.builder(
      itemCount: quadrantItemIds.length,
      itemBuilder: (BuildContext context, int index) {
        Item currentItem = Provider.of<ItemManager>(context, listen: false)
            .items[quadrantItemIds[index]]!;
        return TaskTile(item: currentItem);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<List<String>> classifiedItems =
        Provider.of<ItemManager>(context, listen: false)
            .classifyItemsIntoQuadrants();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Urgent & Important',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: _buildQuadrantListView(context, classifiedItems[0])),
        const Text('Not Urgent & Important',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: _buildQuadrantListView(context, classifiedItems[1])),
        const Text('Urgent & Not Important',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: _buildQuadrantListView(context, classifiedItems[2])),
        const Text('Not Urgent & Not Important',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Expanded(child: _buildQuadrantListView(context, classifiedItems[3])),
      ],
    );
  }
}


/*

Importance 1: 

5 min - 4 days
5 min - 8 days
5 min - 12 days
5 min - 20 days

15 min - 4 days
15 min - 8 days
15 min - 12 days
15 min - 20 days

60 min - 4 days
60 min - 8 days
60 min - 12 days
60 min - 20 days

Importance 3: 

5 min - 4 days
5 min - 8 days
5 min - 12 days
5 min - 20 days

15 min - 4 days
15 min - 8 days
15 min - 12 days
15 min - 20 days

60 min - 4 days
60 min - 8 days
60 min - 12 days
60 min - 20 days

Importance 8: 

5 min - 4 days
5 min - 8 days
5 min - 12 days
5 min - 20 days

15 min - 4 days
15 min - 8 days
15 min - 12 days
15 min - 20 days

60 min - 4 days
60 min - 8 days
60 min - 12 days
60 min - 20 days






*/