import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_tables.dart';
import '../../domain/repositories/i_settings_repository.dart';

class SqliteSettingsRepository implements ISettingsRepository {
  final Database _db;

  SqliteSettingsRepository(this._db);

  @override
  Future<String?> get(String key) async {
    try {
      final List<Map<String, dynamic>> maps = await _db.query(
        DatabaseTables.settingsTable,
        where: 'key = ?',
        whereArgs: [key],
      );

      if (maps.isNotEmpty) {
        return maps.first['value'] as String;
      }
    } catch (e) {
      // Return null if table does not exist or other DB errors
      return null;
    }
    return null;
  }

  @override
  Future<void> set(String key, String value) async {
    try {
      await _db.insert(
        DatabaseTables.settingsTable,
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      // Ignore errors during set if table missing
    }
  }

  @override
  Future<void> delete(String key) async {
    await _db.delete(
      DatabaseTables.settingsTable,
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(DatabaseTables.settingsTable);
  }
}
