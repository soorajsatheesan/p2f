import 'package:path/path.dart' as p;
import 'package:p2f/models/weight_entry.dart';
import 'package:sqflite/sqflite.dart';

class WeightStorageService {
  static const String _dbName = 'p2f_weight.db';
  static const String _tableName = 'weight_entries';

  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            weight_kg REAL NOT NULL,
            logged_at TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<WeightEntry> insertEntry(double weightKg) async {
    final db = await _database();
    final now = DateTime.now();
    final id = await db.insert(_tableName, {
      'weight_kg': weightKg,
      'logged_at': now.toIso8601String(),
    });
    return WeightEntry(id: id, weightKg: weightKg, loggedAt: now);
  }

  Future<List<WeightEntry>> getEntries() async {
    final db = await _database();
    final rows = await db.query(_tableName, orderBy: 'logged_at ASC');
    return rows.map(WeightEntry.fromDbMap).toList();
  }

  Future<void> deleteEntry(int id) async {
    final db = await _database();
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearEntries() async {
    final db = await _database();
    await db.delete(_tableName);
  }
}
