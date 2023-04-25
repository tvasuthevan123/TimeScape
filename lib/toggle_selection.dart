import 'dart:math';

import 'package:flutter/material.dart';

class ToggleButtonSelection extends StatefulWidget {
  final void Function(List<int>)? onPressCallback;
  final List<String> buttonLabels;
  final bool allowMultipleSelection;

  const ToggleButtonSelection({
    Key? key,
    required this.buttonLabels,
    this.onPressCallback,
    this.allowMultipleSelection = false,
  }) : super(key: key);

  @override
  State<ToggleButtonSelection> createState() => _ToggleButtonSelectionState();
}

class _ToggleButtonSelectionState extends State<ToggleButtonSelection> {
  late List<bool> _isSelectedList = [];

  @override
  void initState() {
    super.initState();
    _isSelectedList =
        List.generate(widget.buttonLabels.length, (index) => index == 0);
  }

  void _onPressed(int index) {
    setState(() {
      if (!widget.allowMultipleSelection) {
        _isSelectedList =
            List.generate(widget.buttonLabels.length, (i) => i == index);
      } else {
        _isSelectedList[index] = !_isSelectedList[index];
      }
    });

    if (widget.onPressCallback != null) {
      final selectedIndices = <int>[];
      for (var i = 0; i < _isSelectedList.length; i++) {
        if (_isSelectedList[i]) {
          selectedIndices.add(i);
        }
      }
      widget.onPressCallback!(selectedIndices);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: _isSelectedList,
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
      onPressed: _onPressed,
      children: widget.buttonLabels
          .map((label) => Padding(
                padding: const EdgeInsets.all(1),
                child: Text(label),
              ))
          .toList(),
    );
  }
}
