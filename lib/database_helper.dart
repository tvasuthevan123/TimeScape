import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timescape/entry_manager.dart';
// import 'package:timescape/scheduler.dart';

class DatabaseHelper {
  static const String dbName = 'timescape.db';

  static Database? _database;

  Future<Database> get database async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    // Directory(path).delete(recursive: true);
    if ((await databaseExists(path)) == true) {
      _database = await openDatabase(path);
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE tasks ('
            'id STRING PRIMARY KEY, '
            'title TEXT, '
            'description TEXT, '
            'is_completed INTEGER, '
            'deadline INTEGER, '
            'time_spent INTEGER, '
            'estimated_length INTEGER, '
            'urgency REAL, '
            'importance REAL'
            ')');

        await db.execute('CREATE TABLE events ('
            'id STRING PRIMARY KEY, '
            'title TEXT, '
            'description TEXT, '
            'date INTEGER, '
            'length INTEGER, '
            'reminderTimeBeforeEvent INTEGER, '
            'recurrenceType STRING, '
            'daysOfWeek STRING, '
            'interval INTEGER, '
            ')');

        await db.execute('CREATE TABLE reminder ('
            'id STRING PRIMARY KEY, '
            'title TEXT, '
            'description TEXT, '
            'dateTime INTEGER, '
            ')');

        await db.execute('CREATE TABLE assignments ('
            'id STRING PRIMARY KEY, '
            'timestamp INTEGER, '
            'duration INTEGER, '
            'FOREIGN KEY(id) REFERENCES items(id)'
            ')');
      },
    );
  }

  Future<int> addTask(Task task) async {
    final db = await database;

    return db.insert('tasks', task.toMap());
  }

  Future<int> addEvent(Event event) async {
    final db = await database;

    return db.insert('events', event.toMap());
  }

  Future<int> addReminder(Reminder reminder) async {
    final db = await database;

    return db.insert('reminder', reminder.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('items');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task item) async {
    final db = await database;

    return db
        .update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteTask(Task item) async {
    final db = await database;

    return db.delete('items', where: 'id = ?', whereArgs: [item.id]);
  }

  // Future<int> addAssignment(Assignment assignment) async {
  //   final db = await database;

  //   return db.insert('assignments', assignment.toMap());
  // }

  // Future<List<Assignment>> getAssignments() async {
  //   final db = await database;
  //   final maps = await db.query('assignments');

  //   return List.generate(maps.length, (i) {
  //     return Assignment.fromMap(maps[i]);
  //   });
  // }
}
