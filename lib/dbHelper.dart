import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final databaseName = "daily_database.db";
  static final databaseVersion = 1;

  static final table = 'my_table';

  static final columnDate = 'date';
  static final columnPurchased = 'purchase';

  static final none = 0;
  static final milk = 1;
  static final curd = 2;
  static final milkCurd = 3;

  static final items = ["ಹಾಲು ", "ಮೊಸರು ", "ಹಾಲು - ಮೊಸರು", "ಬೇಡ"];

  // only have a single app-wide reference to the database
  static Database _database;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await openDatabase(
      // Set the path to the database.
      join(await getDatabasesPath(), databaseName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute('''
          CREATE TABLE $table (
            $columnDate INTEGER PRIMARY KEY,
            $columnPurchased INTEGER
          )
          ''');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return _database;
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    print("querying all rows");
    return await db.query(table, orderBy: columnDate);
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.update(table, row,
        where: '$columnDate = ?', whereArgs: [row[columnDate]]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int date) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnDate = ?', whereArgs: [date]);
  }

  // Deletes all the rows. The number of affected rows is
  // returned.
  Future<int> deleteAll() async {
    print("deleting all rows");
    Database db = await instance.database;
    return await db.delete(table);
  }

  // Deletes all the rows. The number of affected rows is
  // returned.
  Future<int> deleteAllBefore(int date) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnDate <= ?', whereArgs: [date]);
  }
}
