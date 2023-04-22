import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timescape/item_manager.dart';
import 'package:timescape/scheduler.dart';

class DatabaseHelper {
  static late Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'my_database.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE items ('
            'id STRING PRIMARY KEY'
            'title TEXT, '
            'description TEXT, '
            'type INTEGER, '
            'is_completed INTEGER, '
            'is_soft_deadline INTEGER, '
            'deadline INTEGER, '
            'time_spent INTEGER, '
            'estimated_length INTEGER, '
            'urgency REAL, '
            'importance REAL'
            ')');

        await db.execute('CREATE TABLE assignments ('
            'id STRING PRIMARY KEY '
            'time INTEGER, '
            'duration INTEGER, '
            'FOREIGN KEY(id) REFERENCES items(id)'
            ')');
      },
    );
  }

  Future<int> addItem(Item item) async {
    final db = await database;

    return db.insert('items', item.toMap());
  }

  Future<List<Item>> getItems() async {
    final db = await database;
    final maps = await db.query('items');

    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<int> updateItem(Item item) async {
    final db = await database;

    return db
        .update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(Item item) async {
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
