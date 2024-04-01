
import 'package:flutter/material.dart';

class ToggleButtonSelection extends StatefulWidget {
  final void Function(List<int>)? onPressCallback;
  final List<String> buttonLabels;
  final bool allowMultipleSelection;

  const ToggleButtonSelection({
    super.key,
    required this.buttonLabels,
    this.onPressCallback,
    this.allowMultipleSelection = false,
  });

  @override
  State<ToggleButtonSelection> createState() => _ToggleButtonSelectionState();
}

class _ToggleButtonSelectionState extends State<ToggleButtonSelection> {
  late List<bool> isSelectedList = [];

  @override
  void initState() {
    super.initState();
    isSelectedList =
        List.generate(widget.buttonLabels.length, (index) => index == 0);
  }

  void onPressed(int index) {
    setState(() {
      if (!widget.allowMultipleSelection) {
        isSelectedList =
            List.generate(widget.buttonLabels.length, (i) => i == index);
      } else {
        isSelectedList[index] = !isSelectedList[index];
      }
    });

    if (widget.onPressCallback != null) {
      final selectedIndices = <int>[];
      for (var i = 0; i < isSelectedList.length; i++) {
        if (isSelectedList[i]) {
          selectedIndices.add(i);
        }
      }
      widget.onPressCallback!(selectedIndices);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: isSelectedList,
      selectedColor: Colors.white,
      color: Colors.blue,
      fillColor: Colors.lightBlue.shade900,
      splashColor: Colors.red,
      highlightColor: Colors.orange,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      renderBorder: true,
      borderColor: Colors.black,
      borderWidth: 1.5,
      borderRadius: BorderRadius.circular(10),
      selectedBorderColor: Colors.pink,
      onPressed: onPressed,
      children: widget.buttonLabels
          .map((label) => Padding(
                padding: const EdgeInsets.all(3),
                child: Text(label),
              ))
          .toList(),
    );
  }
}
