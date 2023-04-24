import 'package:flutter/material.dart';
import 'package:timescape/database_helper.dart';
import 'package:timescape/entry_manager.dart';

class SetupCategoriesPage extends StatefulWidget {
  final VoidCallback setupCompleteCallback;

  const SetupCategoriesPage(this.setupCompleteCallback);

  @override
  State<SetupCategoriesPage> createState() => _SetupCategoriesPageState();
}

class _SetupCategoriesPageState extends State<SetupCategoriesPage> {
  List<TaskCategory> _categories = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setup Categories'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_categories[index].name),
                  onDismissed: (direction) {
                    setState(() {
                      _categories.removeAt(index);
                    });
                  },
                  child: ListTile(
                    title: Text(_categories[index].name),
                    subtitle: Text('Importance: ${_categories[index].value}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _categories.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _addTaskCategory(context);
              },
              child: Text('Add TaskCategory'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _categories.length < 2
                  ? null
                  : () {
                      _saveCategories();
                    },
              child: Text('Save and Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _addTaskCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    bool hasError = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add TaskCategory'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'TaskCategory Name',
                    hintText: 'Enter category name',
                  ),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'TaskCategory Value',
                    hintText: 'Enter category value',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        int? parsedValue = int.tryParse(value);
                        hasError = parsedValue == null;
                        if (!hasError) {}
                      } else {
                        hasError = true;
                      }
                    });
                  },
                ),
                Visibility(
                  visible: hasError,
                  child: Text(
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
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: hasError
                    ? null
                    : () {
                        setState(() {
                          _categories.add(
                            TaskCategory(
                              name: nameController.text,
                              value: int.parse(valueController.text),
                            ),
                          );
                        });
                        Navigator.of(context).pop();
                      },
                child: Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  void _saveCategories() async {
    if (_categories.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least two categories.'),
        ),
      );
      return;
    }

    for (TaskCategory category in _categories) {
      await DatabaseHelper().addCategory(category);
    }

    // Call the setupCompleteCallback to notify the parent widget that the setup is complete
    widget.setupCompleteCallback();
  }
}
