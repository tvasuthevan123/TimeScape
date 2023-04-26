import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timescape/toggle_selection.dart';
import 'package:timescape/date_picker.dart';
import 'package:timescape/duration_picker.dart';

class EntryForm extends StatefulWidget {
  const EntryForm({Key? key}) : super(key: key);
  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  EntryType _entryType = EntryType.task;
  String _entryTitle = '';
  String _entryDescription = '';
  DateTime _dateTime = DateTime.now().add(const Duration(minutes: 30));

  Duration _length = const Duration(hours: 0, minutes: 15);

  Duration _reminderTimeBeforeEvent = const Duration(hours: 0, minutes: 15);
  RecurrenceType _recurrenceType = RecurrenceType.daily;
  List<int> _chosenDays = [];
  int _dayOfMonth = 0;
  int _interval = 0;

  int categoryID = 1;

  final nameController = TextEditingController();
  bool isNotValidParams = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<EntryManager>(builder: (context, itemManager, child) {
      categoryID = itemManager.categories[0].id;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter task name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _entryTitle = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter task description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _entryDescription = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtonSelection(
              buttonLabels: const ['Task', 'Reminder', 'Event'],
              onPressCallback: (selected) {
                setState(() {
                  _entryType = EntryType.values[selected[0]];
                });
              },
            ),
          ),
          if (_entryType == EntryType.task) _taskForm(itemManager),
          if (_entryType == EntryType.event) _eventForm(),
          if (_entryType == EntryType.reminder) _reminderForm(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                Entry entry;
                if (_entryType == EntryType.task) {
                  entry = Task(
                    title: _entryTitle,
                    description: _entryDescription,
                    deadline: _dateTime,
                    estimatedLength: _length,
                    categoryID: categoryID,
                  );
                  await DatabaseHelper().addTask(entry as Task);
                } else if (_entryType == EntryType.event) {
                  entry = Event(
                    title: _entryTitle,
                    description: _entryDescription,
                    length: _length,
                    startTime: TimeOfDay(
                        hour: _dateTime.hour, minute: _dateTime.minute),
                    startDate: _dateTime,
                    reminderTimeBeforeEvent: _reminderTimeBeforeEvent,
                    recurrence: Recurrence(
                      type: _recurrenceType,
                      daysOfWeek: _chosenDays,
                      dayOfMonth: _dayOfMonth,
                      interval: _interval,
                    ),
                  );
                  await DatabaseHelper().addEvent(entry as Event);
                } else if (_entryType == EntryType.reminder) {
                  entry = Reminder(
                    title: _entryTitle,
                    description: _entryDescription,
                    dateTime: _dateTime,
                  );
                  await DatabaseHelper().addReminder(entry as Reminder);
                } else {
                  throw Exception('Invalid entry type: $_entryType');
                }

                Provider.of<EntryManager>(context, listen: false)
                    .addEntry(entry);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          )
        ],
      );
    });
  }

  Widget _taskForm(EntryManager itemManager) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimePicker(
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _dateTime = newDateTime;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DurationPicker(
            initialDuration: _length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                _length = newDuration;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<TaskCategory>(
            value: itemManager.categories[0],
            onChanged: (TaskCategory? category) {
              categoryID = category!.id;
              print(categoryID);
            },
            items: itemManager.categories.map((TaskCategory category) {
              return DropdownMenuItem<TaskCategory>(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reminderForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimePicker(
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _dateTime = newDate;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _eventForm() {
    const List<String> daysOfWeek = [
      "Mon",
      "Tues",
      "Wed",
      "Thurs",
      "Fri",
      "Sat",
      "Sun"
    ];

    Widget _renderDateTime(bool showDate, bool showTime) {
      return Column(
        children: [
          DateTimePicker(
            showDate: showDate,
            showTime: showTime,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _dateTime = newDate;
              });
            },
          ),
          SizedBox(height: 16),
        ],
      );
    }

    Widget _renderDuration() {
      return Column(
        children: [
          DurationPicker(
            initialDuration: _length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                _length = newDuration;
              });
            },
          ),
        ],
      );
    }

    Widget _renderTimeBeforeAlert() {
      return Column(
        children: [
          DurationPicker(
            initialDuration: _length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                _reminderTimeBeforeEvent = newDuration;
              });
            },
          ),
        ],
      );
    }

    Widget _renderDaysOfWeek() {
      return ToggleButtonSelection(
        buttonLabels: daysOfWeek,
        allowMultipleSelection: true,
        onPressCallback: (indices) {
          setState(() {
            _chosenDays = indices;
          });
        },
      );
    }

    Widget _renderDayOfMonth() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Day of month',
            hintText: 'Enter day of month (1-31)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a day of the month';
            }
            final dayOfMonth = int.tryParse(value);
            if (dayOfMonth == null || dayOfMonth < 1 || dayOfMonth > 31) {
              return 'Please enter a valid day of the month';
            }
            return null;
          },
          onSaved: (value) {
            setState(() {
              _dayOfMonth = int.tryParse(value!)!;
            });
          },
        ),
      );
    }

    Widget _renderCustomInterval() {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Interval',
            hintText: 'Enter interval (in days)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter an interval';
            }
            final interval = int.tryParse(value);
            if (interval == null || interval < 1) {
              return 'Please enter a valid interval';
            }
            return null;
          },
          onSaved: (value) {
            setState(() {
              _interval = int.tryParse(value!)!;
            });
          },
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Alert Time before Event"),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Reminder time before deadline',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _renderTimeBeforeAlert(),
          ),
        ),
        const SizedBox(height: 16),
        ToggleButtonSelection(
          buttonLabels: const [
            'One Off',
            'Daily',
            'Weekly',
            'Monthly',
            'Custom Interval',
          ],
          onPressCallback: (index) {
            setState(() {
              _recurrenceType = RecurrenceType.values[index[0]];
            });
          },
        ),
        const SizedBox(height: 16),
        if (_recurrenceType == RecurrenceType.oneOff) ...[
          _renderDateTime(true, true),
        ] else if (_recurrenceType == RecurrenceType.daily) ...[
          _renderDateTime(false, true),
        ] else if (_recurrenceType == RecurrenceType.weekly) ...[
          _renderDateTime(false, true),
          const SizedBox(height: 16),
          _renderDaysOfWeek(),
        ] else if (_recurrenceType == RecurrenceType.custom) ...[
          _renderDateTime(true, true),
          const SizedBox(height: 16),
          _renderCustomInterval(),
        ],
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Duration"),
        ),
        _renderDuration(),
      ],
    );
  }
}
