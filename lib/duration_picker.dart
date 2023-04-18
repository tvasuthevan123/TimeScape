import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final void Function(Duration duration) onDurationChanged;

  const DurationPicker({
    Key? key,
    required this.initialDuration,
    required this.onDurationChanged,
  }) : super(key: key);

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int _hours;
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _hours = widget.initialDuration.inHours;
    _minutes = widget.initialDuration.inMinutes % 60;
  }

  void _handleHourChange(int newHours) {
    setState(() {
      _hours = newHours;
      widget.onDurationChanged(Duration(hours: _hours, minutes: _minutes));
    });
  }

  void _handleMinuteChange(int newMinutes) {
    setState(() {
      _minutes = newMinutes;
      widget.onDurationChanged(Duration(hours: _hours, minutes: _minutes));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => _handleHourChange(_hours - 1),
          icon: Icon(Icons.remove),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '$_hours h',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => _handleHourChange(_hours + 1),
          icon: Icon(Icons.add),
        ),
        IconButton(
          onPressed: () => _handleMinuteChange(_minutes - 1),
          icon: Icon(Icons.remove),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '$_minutes min',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => _handleMinuteChange(_minutes + 1),
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
