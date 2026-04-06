import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_tables.dart';
import 'database_seeder.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final defaultPath = await getDatabasesPath();
    final path = join(defaultPath, 'flow_database.db');

    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    // Safety fallback to prevent 'no such table' errors if migrations missed
    try {
      await db.execute(DatabaseTables.createSettingsTable);
    } catch (_) {}

    return db;
  }

  Future<void> _onConfigure(Database db) async {
    // Enforce foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createTransactionsTable);
    await db.execute(DatabaseTables.createSettingsTable);
    
    // Seed initial data
    await DatabaseSeeder.seedInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(DatabaseTables.createSettingsTable);
    }
  }
}
