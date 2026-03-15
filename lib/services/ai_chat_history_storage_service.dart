import 'package:path/path.dart' as p;
import 'package:p2f/models/chat_message.dart';
import 'package:sqflite/sqflite.dart';

class AiChatHistoryStorageService {
  static const String _dbName = 'p2f_ai_chat.db';
  static const String _tableName = 'chat_messages';

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
            companion_id TEXT NOT NULL,
            role TEXT NOT NULL,
            text TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE INDEX idx_${_tableName}_companion_created_at
          ON $_tableName (companion_id, created_at)
        ''');
      },
    );

    return _db!;
  }

  Future<List<ChatMessage>> getMessages(String companionId) async {
    final db = await _database();
    final rows = await db.query(
      _tableName,
      where: 'companion_id = ?',
      whereArgs: [companionId],
      orderBy: 'created_at ASC, id ASC',
    );

    return rows
        .map(
          (row) => ChatMessage(
            role: ChatRole.fromStorage(row['role'] as String? ?? 'assistant'),
            text: row['text'] as String? ?? '',
            createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList(growable: false);
  }

  Future<void> insertMessage({
    required String companionId,
    required ChatMessage message,
  }) async {
    final db = await _database();
    await db.insert(_tableName, {
      'companion_id': companionId,
      'role': message.role.name,
      'text': message.text,
      'created_at': message.createdAt.toIso8601String(),
    });
  }

  Future<void> clearCompanionHistory(String companionId) async {
    final db = await _database();
    await db.delete(
      _tableName,
      where: 'companion_id = ?',
      whereArgs: [companionId],
    );
  }

  Future<void> clearAllHistory() async {
    final db = await _database();
    await db.delete(_tableName);
  }
}
