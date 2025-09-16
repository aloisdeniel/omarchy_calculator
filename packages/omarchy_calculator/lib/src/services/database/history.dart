import 'package:calc_engine/calc_engine.dart';
import 'package:omarchy_calculator/src/services/database/database.dart';
import 'package:sqflite_common/sqlite_api.dart';

class HistoryItem {
  HistoryItem({
    required this.id,
    required this.commands,
    required this.result,
    required this.timestamp,
  });

  final int id;
  final List<Command> commands;
  final Decimal result;
  final DateTime timestamp;

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    List<Command> commands;
    try {
      commands = Command.parse(map['commands'] as String);
    } catch (_) {
      commands = const [];
    }
    return HistoryItem(
      id: map['id'] as int,
      commands: commands,
      result: Decimal.parse(map['result'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

abstract class HistoryTable implements Table {
  const factory HistoryTable.sql(Database db) = SqlHistoryTable;

  factory HistoryTable.memory() = MemoryHistoryTable;

  Future<FetchResult<HistoryItem>> getAll([int take = 1000, int? skip]);

  Future<HistoryItem> insert(List<Command> commands, Decimal result);

  Future<int> clear();

  Future<void> delete(int id);
}

class SqlHistoryTable extends SqlTable implements HistoryTable {
  const SqlHistoryTable(super.db);

  @override
  String get name => 'history';

  @override
  Future<void> createTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $name (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commands TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  @override
  Future<HistoryItem> insert(List<Command> commands, Decimal result) async {
    final id = await db.insert(name, {
      'commands': commands.map((x) => x.serialize()).join(),
      'result': result.toString(),
    });
    return HistoryItem(
      id: id,
      commands: commands,
      result: result,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<void> delete(int id) async {
    await db.delete(name, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<FetchResult<HistoryItem>> getAll([int take = 1000, int? skip]) async {
    final result = await db.query(
      name,
      orderBy: 'timestamp DESC',
      limit: take,
      offset: skip,
    );
    final results = result.map((e) => HistoryItem.fromMap(e)).toList();
    final total = await db.rawQuery('SELECT COUNT(*) as count FROM $name');
    final offset = skip ?? 0;
    return FetchResult(
      offset,
      results,
      offset + results.length < (total.first['count'] as int),
    );
  }

  @override
  Future<int> clear() async {
    return await db.delete(name);
  }
}

class MemoryHistoryTable implements HistoryTable {
  MemoryHistoryTable();

  static int _nextId = 1;

  final List<HistoryItem> _items = [];

  @override
  Future<int> clear() async {
    final count = _items.length;
    _items.clear();
    return count;
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<FetchResult<HistoryItem>> getAll([int take = 1000, int? skip]) async {
    final offset = skip ?? 0;
    final items = _items.skip(offset).take(take).toList();
    return FetchResult(offset, items, offset + items.length < _items.length);
  }

  @override
  Future<HistoryItem> insert(List<Command> commands, Decimal result) async {
    final item = HistoryItem(
      id: _nextId++,
      commands: commands,
      result: result,
      timestamp: DateTime.now(),
    );
    _items.add(item);
    return item;
  }
}
