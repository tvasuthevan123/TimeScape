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
    final screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Material(
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
                    color: const Color.fromRGBO(0, 78, 82, 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    "Setup Categories",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(_categories[index].name),
                    onDismissed: (direction) {
                      setState(() async {
                        await DatabaseHelper()
                            .deleteCategory(_categories[index]);
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
      ),
    );
  }

  void _addTaskCategory(BuildContext context) async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    bool isNotValidParams = true;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'Enter category name',
                  ),
                ),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Category Value',
                    hintText: 'Enter importance value (higher = more priority)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        int? parsedValue = int.tryParse(value);
                        isNotValidParams = parsedValue == null;
                      } else {
                        isNotValidParams = true;
                      }
                    });
                  },
                ),
                Visibility(
                  visible: isNotValidParams,
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
                onPressed: isNotValidParams
                    ? () {}
                    : () async {
                        TaskCategory category = TaskCategory(
                          name: nameController.text,
                          value: int.parse(valueController.text),
                        );
                        _categories.add(category);
                        category.id =
                            await DatabaseHelper().addCategory(category);
                        // Close the dialog
                        Navigator.of(context).pop();
                        // Refresh the state of the SetupCategoriesPage
                        setState(() {});
                      },
                child: Text('Submit'),
              ),
            ],
          );
        });
      },
    );

    // Update the state of the parent widget after closing the dialog
    setState(() {});
  }

  void updateMainState() {
    setState(() {});
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

    // Call the setupCompleteCallback to notify the parent widget that the setup is complete
    widget.setupCompleteCallback();
  }
}
