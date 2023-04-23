import 'package:flutter/material.dart';

//TODO Multi selection

class ToggleButtonSelection extends StatefulWidget {
  final void Function(int) onPressCallback;
  const ToggleButtonSelection(
      {super.key, this.onPressCallback = _defaultOnPressCallback});

  static void _defaultOnPressCallback(int selected) {
    print('Selected: $selected');
  }

  @override
  State<ToggleButtonSelection> createState() => _ToggleButtonSelectionState();
}

class _ToggleButtonSelectionState extends State<ToggleButtonSelection> {
  int _selectedButtonIndex = 0;

  void _onPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
    });
    widget.onPressCallback(index);
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        _selectedButtonIndex == 0,
        _selectedButtonIndex == 1,
        _selectedButtonIndex == 2
      ],
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
      children: const [
        Text('Task'),
        Text('Reminder'),
        Text('Event'),
      ],
    );
  }
}
