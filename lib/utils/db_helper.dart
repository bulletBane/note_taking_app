import 'package:note_taking_app/models/mote.dart';
import 'package:path/path.dart';
import 'dart:async';

import 'package:sqflite/sqflite.dart';

class NotesDBHandler {
  final databaseName = "notes.db";
  final tableName = "notes";

  final fieldMap = {
    "id": "INTEGER PRIMARY KEY AUTOINCREMENT",
    "title": "BLOB",
    "content": "BLOB",
    "date_created": "INTEGER",
    "date_last_edited": "INTEGER",
    "note_color": "INTEGER",
    "is_archived": "INTEGER"
  };

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    var path = await getDatabasesPath();
    var dbPath = join(path, 'notes.db');
    Database dbConnection = await openDatabase(dbPath, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(_buildCreateQuery());
    });

    await dbConnection.execute(_buildCreateQuery());
    _buildCreateQuery();
    return dbConnection;
  }

  String _buildCreateQuery() {
    String query = "CREATE TABLE IF NOT EXISTS ";
    query += tableName;
    query += "(";
    fieldMap.forEach((column, field) {
      query += "$column $field,";
    });

    query = query.substring(0, query.length - 1);
    query += " )";

    return query;
  }

  static Future<String> dbPath() async {
    String path = await getDatabasesPath();
    return path;
  }

  Future<int> insertNote(Note note, bool isNew) async {
    final Database db = await database;

    await db.insert(
      'notes',
      isNew ? note.toMap(false) : note.toMap(true),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    if (isNew) {
      var one = await db.query("notes",
          orderBy: "date_last_edited desc",
          where: "is_archived = ?",
          whereArgs: [0],
          limit: 1);
      int latestId = one.first["id"] as int;
      return latestId;
    }
    return note.id;
  }

  Future<bool> copyNote(Note note) async {
    final Database db = await database;
    try {
      await db.insert("notes", note.toMap(false),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (Error) {
      return false;
    }
    return true;
  }

  Future<void> archiveNote(Note note) async {
    if (note.id != -1) {
      final Database db = await database;

      int idToUpdate = note.id;

      db.update("notes", note.toMap(true),
          where: "id = ?", whereArgs: [idToUpdate]);
    }
  }

  Future<void> deleteNote(Note note) async {
    if (note.id != -1) {
      final Database db = await database;
      try {
        await db.delete("notes", where: "id = ?", whereArgs: [note.id]);
        return true;
      } catch (Error) {
        return false;
      }
    }
  }

  Future<List<Map<String, dynamic>>> selectAllNotes() async {
    final Database db = await database;
    var data = await db.query("notes",
        orderBy: "date_last_edited desc",
        where: "is_archived = ?",
        whereArgs: [0]);

    return data;
  }
}
