import 'package:calc_engine/calc_engine.dart';
import 'package:omarchy_calculator/src/services/database/database.dart';

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
    return HistoryItem(
      id: map['id'] as int,
      commands: Command.parse(map['commands'] as String),
      result: Decimal.parse(map['result'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class HistoryTable extends Table {
  const HistoryTable(super.db);

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

  Future<void> delete(int id) async {
    await db.delete(name, where: 'id = ?', whereArgs: [id]);
  }

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

  Future<int> clear() async {
    return await db.delete(name);
  }
}
