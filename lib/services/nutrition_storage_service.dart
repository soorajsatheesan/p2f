import 'package:path/path.dart' as p;
import 'package:p2f/models/nutrition_entry.dart';
import 'package:sqflite/sqflite.dart';

class NutritionStorageService {
  static const String _dbName = 'p2f_nutrition.db';
  static const String _tableName = 'nutrition_entries';

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
            image_path TEXT NOT NULL,
            description TEXT NOT NULL,
            created_at TEXT NOT NULL,
            calories INTEGER NOT NULL,
            protein_g REAL NOT NULL,
            carbs_g REAL NOT NULL,
            fats_g REAL NOT NULL,
            fiber_g REAL NOT NULL,
            summary TEXT NOT NULL
          )
        ''');
      },
    );

    return _db!;
  }

  Future<NutritionEntry> insertEntry(NutritionEntry entry) async {
    final db = await _database();
    final id = await db.insert(_tableName, entry.toDbMap());
    return entry.copyWith(id: id);
  }

  Future<List<NutritionEntry>> getEntries() async {
    final db = await _database();
    final rows = await db.query(_tableName, orderBy: 'created_at DESC');
    return rows.map(NutritionEntry.fromDbMap).toList();
  }
}
