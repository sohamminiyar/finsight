class DatabaseTables {
  static const String categoriesTable = 'categories';
  static const String transactionsTable = 'transactions';
  static const String settingsTable = 'settings';

  static const String createCategoriesTable = '''
    CREATE TABLE $categoriesTable (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      icon_path TEXT NOT NULL,
      color_hex TEXT NOT NULL,
      type TEXT NOT NULL
    )
  ''';

  static const String createTransactionsTable = '''
    CREATE TABLE $transactionsTable (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      category_id TEXT NOT NULL,
      amount REAL NOT NULL,
      note TEXT NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE RESTRICT
    )
  ''';

  static const String createSettingsTable = '''
    CREATE TABLE IF NOT EXISTS $settingsTable (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';
}
