import 'package:flutter/material.dart';

class DurationPicker extends StatefulWidget {
  final Duration initialDuration;
  final void Function(Duration duration) onDurationChanged;

  const DurationPicker({
    super.key,
    required this.initialDuration,
    required this.onDurationChanged,
  });

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late int hours;
  late int minutes;

  @override
  void initState() {
    super.initState();
    hours = widget.initialDuration.inHours;
    minutes = widget.initialDuration.inMinutes % 60;
  }

  void handleHourChange(int newHours) {
    if (newHours >= 0) {
      setState(() {
        hours = newHours;
        widget.onDurationChanged(Duration(hours: hours, minutes: minutes));
      });
    }
  }

  void handleMinuteChange(int newMinutes) {
    if (newMinutes >= 0 && newMinutes <= 60) {
      setState(() {
        minutes = newMinutes;
        widget.onDurationChanged(Duration(hours: hours, minutes: minutes));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => handleHourChange(hours - 1),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '$hours h',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => handleHourChange(hours + 1),
          icon: const Icon(Icons.add),
        ),
        IconButton(
          onPressed: () => handleMinuteChange(minutes - 1),
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 60,
          child: Text(
            '$minutes min',
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () => handleMinuteChange(minutes + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
