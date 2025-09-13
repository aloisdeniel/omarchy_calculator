import 'dart:async';

import 'package:omarchy_calculator/src/services/database/history.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static AppDatabase get instance {
    if (_instance == null) {
      throw Exception("Database not initialized");
    }
    return _instance!;
  }

  static Future<void> init() async {
    if (_instance != null) {
      return;
    }

    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    final appDocumentsDir = await getApplicationDocumentsDirectory();

    final dbPath = p.join(appDocumentsDir.path, "data.db");
    final db = await databaseFactory.openDatabase(dbPath);

    final result = AppDatabase._(db);

    for (final table in result.tables) {
      await table.createTable();
    }

    _instance = result;
  }

  AppDatabase._(Database db) : history = HistoryTable(db);

  final HistoryTable history;

  List<Table> get tables => [history];
}

abstract class Table {
  const Table(this.db);
  final Database db;

  String get name;

  Future<void> createTable();
}

class FetchResult<T> {
  FetchResult(this.offset, this.items, this.hasMore);
  final int offset;
  final List<T> items;
  final bool hasMore;
}
