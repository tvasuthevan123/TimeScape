import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/entry_manager.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback setupCompleteCallback;

  const SettingsPage({super.key, required this.setupCompleteCallback});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  DateTime selectedTimeStart = DateTime(1, 1, 1, 9, 0);
  DateTime selectedTimeEnd = DateTime(1, 1, 1, 17, 0);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Consumer<EntryManager>(builder: (context, itemManager, child) {
      return SafeArea(
        child: Material(
          color: const Color.fromARGB(255, 235, 254, 255),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.zero,
                child: Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 39, 41, 1),
                        width: 2.0,
                      ),
                      color: Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Setup Work Hours",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: Color.fromRGBO(0, 39, 41, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      selectTimeStart(context, (DateTime selectedTime) async {
                        await itemManager.setStartWorkTime(
                            selectedTime.hour * 60 + selectedTime.minute);
                      });
                    },
                    child: SizedBox(
                      width: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Work Day Start',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(selectedTimeStart),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      selectTimeEnd(context, (DateTime selectedTime) async {
                        await itemManager.setEndWorkTime(
                            selectedTime.hour * 60 + selectedTime.minute);
                      });
                    },
                    child: SizedBox(
                      width: 150,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Work Day End',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(selectedTimeEnd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: EdgeInsets.zero,
                child: Center(
                  child: Container(
                    width: screenWidth * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color.fromRGBO(0, 39, 41, 1),
                        width: 2.0,
                      ),
                      color: Colors.transparent,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Setup Categories",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: Color.fromRGBO(0, 39, 41, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: itemManager.categories.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(itemManager.categories[index].name),
                        onDismissed: (direction) async {
                          await DatabaseHelper()
                              .deleteCategory(itemManager.categories[index]);
                          setState(() {
                            itemManager.categories.removeAt(index);
                          });
                        },
                        child: ListTile(
                          title: Text(itemManager.categories[index].name),
                          subtitle: Text(
                              'Importance: ${itemManager.categories[index].value}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await DatabaseHelper().deleteCategory(
                                  itemManager.categories[index]);
                              setState(() {
                                itemManager.categories.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: ElevatedButton(
                  onPressed: () {
                    addTaskCategory(context, itemManager);
                  },
                  child: const Text('Add Category'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                child: ElevatedButton(
                  onPressed: itemManager.categories.length < 2
                      ? null
                      : () {
                          saveCategories(itemManager);
                        },
                  child: const Text('Save and Continue'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void addTaskCategory(BuildContext context, EntryManager itemManager) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    bool isNotValidParams = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                  ),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Importance',
                    hintText: '1-10 (Most Important)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        int? parsedValue = int.tryParse(value);
                        isNotValidParams = parsedValue == null ||
                            (parsedValue > 10 || parsedValue < 1);
                      } else {
                        isNotValidParams = true;
                      }
                    });
                  },
                ),
                Visibility(
                  visible: isNotValidParams,
                  child: const Text(
                    'Please enter a valid number for category value',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isNotValidParams
                    ? () {}
                    : () async {
                        TaskCategory category = TaskCategory(
                          name: nameController.text,
                          value: int.parse(valueController.text),
                        );
                        category.id =
                            await DatabaseHelper().addCategory(category);
                        itemManager.addCategory(category);
                        Navigator.of(context).pop();
                        updateMainState();
                      },
                child: const Text('Submit'),
              ),
            ],
          );
        });
      },
    );

    updateMainState();
  }

  void updateMainState() {
    setState(() {});
  }

  void saveCategories(EntryManager itemManager) async {
    if (itemManager.categories.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least two categories.'),
        ),
      );
      return;
    }

    widget.setupCompleteCallback();
  }

  Future<void> selectTimeStart(
      BuildContext context, Future<void> Function(DateTime) callback) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTimeStart),
    );
    if (picked != null) {
      setState(() {
        selectedTimeStart = DateTime(
          1,
          1,
          1,
          picked.hour,
          picked.minute,
        );
      });
      await callback(selectedTimeStart);
    }
  }

  Future<void> selectTimeEnd(
      BuildContext context, Future<void> Function(DateTime) callback) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTimeEnd),
    );
    if (picked != null) {
      setState(() {
        selectedTimeEnd = DateTime(
          1,
          1,
          1,
          picked.hour,
          picked.minute,
        );
      });
      await callback(selectedTimeEnd);
    }
  }
}
