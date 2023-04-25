import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timescape/scheduler.dart';
import 'package:timescape/entry_manager.dart';
import 'package:timescape/category_setup.dart';
// import 'package:timescape/scheduler.dart';

class DatabaseHelper {
  static const String dbName = 'timescape.db';

  static Database? _database;

  Future<Database> get database async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    // print("Database $path");
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
    print("Init Database $path");

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
            'startTime  INTEGER, '
            'startDate INTEGER, '
            'length INTEGER, '
            'reminderTimeBeforeEvent INTEGER, '
            'recurrenceType STRING, '
            'daysOfWeek STRING, '
            'dayOfMonth INTEGER, '
            'interval INTEGER '
            ')');

        await db.execute('CREATE TABLE reminders ('
            'id STRING PRIMARY KEY, '
            'title TEXT, '
            'description TEXT, '
            'dateTime INTEGER '
            ')');

        await db.execute('CREATE TABLE assignments ('
            'id STRING PRIMARY KEY, '
            'timestamp INTEGER, '
            'duration INTEGER, '
            'FOREIGN KEY(id) REFERENCES items(id)'
            ')');

        await db.execute('CREATE TABLE categories ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name STRING, '
            'value INTEGER '
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

    return db.insert('reminders', reminder.toMap());
  }

  Future<int> addCategory(TaskCategory category) async {
    final db = await database;

    return db.insert('categories', category.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final maps = await db.query('tasks');

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> updateTask(Task item) async {
    final db = await database;

    return db
        .update('tasks', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteTask(Task item) async {
    final db = await database;

    return db.delete('tasks', where: 'id = ?', whereArgs: [item.id]);
  }

  Future<List<Reminder>> getReminders() async {
    final db = await database;
    final maps = await db.query('reminders');

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future<int> updateReminder(Reminder item) async {
    final db = await database;

    return db.update('reminders', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteReminder(Reminder item) async {
    final db = await database;

    return db.delete('reminders', where: 'id = ?', whereArgs: [item.id]);
  }

  Future<List<Event>> getEvents() async {
    final db = await database;
    final maps = await db.query('events');

    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<int> updateEvent(Event item) async {
    final db = await database;

    return db
        .update('events', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteEvent(Event item) async {
    final db = await database;

    return db.delete('events', where: 'id = ?', whereArgs: [item.id]);
  }

  Future<List<TaskCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return TaskCategory.fromMap(maps[i]);
    });
  }

  Future<int> deleteCategory(TaskCategory category) async {
    final db = await database;

    return db.delete('events', where: 'id = ?', whereArgs: [category.id]);
  }

  Future<List<String>> getEventsHappeningToday() async {
    final today = DateTime.now();
    final todayStart =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    final todayEnd = todayStart + Duration(days: 1).inMilliseconds - 1;

    final db = await database;
    final results = await db.rawQuery('''
    SELECT id
    FROM events
    WHERE startDate BETWEEN $todayStart AND $todayEnd
  ''');

    return results.map((result) => result['id'] as String).toList();
  }

  // Future<List<Assignment>> getAssignments() async {
  //   final db = await database;
  //   final maps = await db.query('assignments');

  //   return List.generate(maps.length, (i) {
  //     return Assignment.fromMap(maps[i]);
  //   });
  // }

  // Future<int> updateAssignment(Assignment item) async {
  //   final db = await database;

  //   return db.update('assignments', item.toMap(),
  //       where: 'id = ?', whereArgs: [item.id]);
  // }

  // Future<int> deleteAssignment(Assignment item) async {
  //   final db = await database;

  //   return db.delete('assignments', where: 'id = ?', whereArgs: [item.id]);
  // }
}
