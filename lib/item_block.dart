import 'package:flutter/material.dart';

class ItemBlock extends StatelessWidget {
  final String text;

  const ItemBlock({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable(
      data: text,
      feedback: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blueGrey.withOpacity(0.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      childWhenDragging: Container(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blueGrey,
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
