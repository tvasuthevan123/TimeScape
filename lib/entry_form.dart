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
  EntryType entryType = EntryType.task;
  String entryTitle = '';
  String entryDescription = '';
  DateTime dateTime = DateTime.now().add(const Duration(minutes: 30));

  Duration length = const Duration(hours: 0, minutes: 15);

  Duration timeBeforeEventReminder = const Duration(hours: 0, minutes: 15);
  RecurrenceType recurrenceType = RecurrenceType.oneOff;
  List<int> chosenDays = [];
  int dayOfMonth = 0;
  int interval = 0;

  int categoryID = 1;

  final nameController = TextEditingController();
  bool isSubmittable = false;

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
                  entryTitle = value;
                  if (value.isNotEmpty) {
                    isSubmittable = true;
                  } else {
                    isSubmittable = false;
                  }
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
                  entryDescription = value;
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
                  entryType = EntryType.values[selected[0]];
                });
              },
            ),
          ),
          if (entryType == EntryType.task) taskForm(itemManager),
          if (entryType == EntryType.event) eventForm(),
          if (entryType == EntryType.reminder) reminderForm(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: isSubmittable
                  ? () async {
                      Entry entry;
                      if (entryType == EntryType.task) {
                        entry = Task(
                          title: entryTitle,
                          description: entryDescription,
                          deadline: dateTime,
                          estimatedLength: length,
                          categoryID: categoryID,
                        );
                        await DatabaseHelper().addTask(entry as Task);
                      } else if (entryType == EntryType.event) {
                        entry = Event(
                          title: entryTitle,
                          description: entryDescription,
                          length: length,
                          startTime: TimeOfDay(
                              hour: dateTime.hour, minute: dateTime.minute),
                          startDate: dateTime,
                          reminderTimeBeforeEvent: timeBeforeEventReminder,
                          recurrence: Recurrence(
                            type: recurrenceType,
                            daysOfWeek: chosenDays,
                            dayOfMonth: dayOfMonth,
                            interval: interval,
                          ),
                        );
                        await DatabaseHelper().addEvent(entry as Event);
                      } else if (entryType == EntryType.reminder) {
                        entry = Reminder(
                          title: entryTitle,
                          description: entryDescription,
                          dateTime: dateTime,
                        );
                        await DatabaseHelper().addReminder(entry as Reminder);
                      } else {
                        throw Exception('Invalid entry type: $entryType');
                      }

                      Provider.of<EntryManager>(context, listen: false)
                          .addEntry(entry);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Submit'),
            ),
          )
        ],
      );
    });
  }

  Widget taskForm(EntryManager itemManager) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Deadline",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimePicker(
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                dateTime = newDateTime;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DurationPicker(
            initialDuration: length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                length = newDuration;
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

  Widget reminderForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimePicker(
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                dateTime = newDate;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget eventForm() {
    const List<String> daysOfWeek = [
      "Mon",
      "Tues",
      "Wed",
      "Thurs",
      "Fri",
      "Sat",
      "Sun"
    ];

    Widget renderDateTime(bool showDate, bool showTime) {
      return Column(
        children: [
          DateTimePicker(
            showDate: showDate,
            showTime: showTime,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                dateTime = newDate;
              });
            },
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    Widget renderDuration() {
      return Column(
        children: [
          DurationPicker(
            initialDuration: length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                length = newDuration;
              });
            },
          ),
        ],
      );
    }

    Widget renderTimeBeforeAlert() {
      return Column(
        children: [
          DurationPicker(
            initialDuration: length,
            onDurationChanged: (Duration newDuration) {
              setState(() {
                timeBeforeEventReminder = newDuration;
              });
            },
          ),
        ],
      );
    }

    Widget renderDaysOfWeek() {
      return ToggleButtonSelection(
        buttonLabels: daysOfWeek,
        allowMultipleSelection: true,
        onPressCallback: (indices) {
          setState(() {
            chosenDays = indices;
          });
        },
      );
    }

    Widget renderCustomInterval() {
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
              interval = int.tryParse(value!)!;
            });
          },
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Alert Time before Event",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              )),
        ),
        renderTimeBeforeAlert(),
        const SizedBox(height: 16),
        ToggleButtonSelection(
          buttonLabels: const [
            'One Off',
            'Daily',
            'Weekly',
            'Custom Interval',
          ],
          onPressCallback: (index) {
            setState(() {
              recurrenceType = RecurrenceType.values[index[0]];
            });
          },
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Event Date/Time",
              style: TextStyle(
                fontWeight: FontWeight.w900,
              )),
        ),
        const SizedBox(height: 12),
        if (recurrenceType == RecurrenceType.oneOff) ...[
          renderDateTime(true, true),
        ] else if (recurrenceType == RecurrenceType.daily) ...[
          renderDateTime(false, true),
        ] else if (recurrenceType == RecurrenceType.weekly) ...[
          renderDateTime(false, true),
          const SizedBox(height: 16),
          renderDaysOfWeek(),
          const SizedBox(height: 16),
        ] else if (recurrenceType == RecurrenceType.custom) ...[
          renderDateTime(true, true),
          const SizedBox(height: 16),
          renderCustomInterval(),
        ],
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Duration",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        renderDuration(),
      ],
    );
  }
}
