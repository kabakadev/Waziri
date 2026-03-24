import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // 1. Create a Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // 2. Open the connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('waziri.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 3. Create the Tables
  Future _createDB(Database db, int version) async {
    // Note: SQLite doesn't have a native boolean type. We use INTEGER (0 for false, 1 for true).

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL, 
        is_regretted INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        date TEXT NOT NULL, 
        is_debt INTEGER NOT NULL DEFAULT 0,
        debt_reason TEXT, 
        is_savings_drawdown INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        monthly_budget REAL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        delta REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');

    // 4. Seed the default categories immediately upon creation
    await _seedDefaultCategories(db);
  }

  // 5. Pre-fill the database so the user isn't looking at a blank app
  Future _seedDefaultCategories(Database db) async {
    final defaultCategories = [
      {
        'name': 'Food & Groceries',
        'icon': 'shopping_cart',
        'color': 0xFF7A9E7E,
        'is_default': 1,
      },
      {
        'name': 'Transport',
        'icon': 'directions_bus',
        'color': 0xFF7A9E7E,
        'is_default': 1,
      },
      {'name': 'Housing', 'icon': 'home', 'color': 0xFF7A9E7E, 'is_default': 1},
      {
        'name': 'Impulse/Wants',
        'icon': 'local_fire_department',
        'color': 0xFFD4614A,
        'is_default': 1,
      },
      {
        'name': 'Debt Repayment',
        'icon': 'account_balance_wallet',
        'color': 0xFFE8A135,
        'is_default': 1,
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // 6. Close the database (Rarely needed in a mobile app, but good practice)
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
