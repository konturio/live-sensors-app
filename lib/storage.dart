import 'package:flutter/widgets.dart';
import 'package:live_sensors/snapshot.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'logger.dart';

class Storage {
  final Logger logger = Logger();
  Storage();
  final dbName = 'snapshots.db';
  late Future<Database> database;

  Future<void> init() async {
    // Avoid errors caused by flutter upgrade.
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), dbName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> save(Snapshot snapshot) async {
    final db = await database;

    await db.insert(
      'snapshots',
      snapshot.toJson(),
      // specify the `conflictAlgorithm` to use
      // in case the same entry is inserted twice.
      conflictAlgorithm:
          ConflictAlgorithm.replace, // replace any previous data.
    );
  }

  Future<void> delete(Snapshot snapshot) async {
    final db = await database;

    await db.delete('snapshots',
        where: 'id = ?',
        // Pass the id as a whereArg to prevent SQL injection.
        whereArgs: [snapshot.id]);
  }

  Future<Snapshot> next() async {
    throw Error();
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query('snapshots', where: 'error = ?');
  }
}
