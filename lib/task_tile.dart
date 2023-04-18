import 'package:flutter/material.dart';
import 'package:timescape/item_manager.dart';

class TaskTile extends StatefulWidget {
  final Item item;
  const TaskTile({Key? key, required this.item}) : super(key: key);

  @override
  _TaskTileState createState() => _TaskTileState();
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
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 200 : 0,
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color.fromRGBO(0, 39, 41, 1),
                  width: 2.0,
                ),
                color: const Color.fromRGBO(214, 253, 255, 1),
              ),
              padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
              child: Text(
                widget.item.description,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color.fromRGBO(0, 58, 61, 1),
                ),
              ),
            ),
            Container(
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
          ],
        ),
      ),
    );
  }
}
