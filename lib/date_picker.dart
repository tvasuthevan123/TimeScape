import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime) onDateTimeChanged;
  final bool showDate;
  final bool showTime;

  const DateTimePicker({
    Key? key,
    required this.onDateTimeChanged,
    this.showDate = true,
    this.showTime = true,
  }) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now().add(const Duration(minutes: 30));
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDateTime) {
      setState(() {
        selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        );
      });
      widget.onDateTimeChanged(selectedDateTime);
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
      widget.onDateTimeChanged(selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (widget.showDate) {
      children.add(
        InkWell(
          onTap: () {
            selectDate(context);
          },
          child: SizedBox(
            width: 150,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(selectedDateTime),
              ),
            ),
          ),
        ),
      );
      children.add(const SizedBox(width: 8));
    }
    if (widget.showTime) {
      children.add(
        InkWell(
          onTap: () {
            selectTime(context);
          },
          child: SizedBox(
            width: 150,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              child: Text(
                DateFormat('HH:mm').format(selectedDateTime),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
