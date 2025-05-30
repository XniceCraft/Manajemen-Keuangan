import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'database_factory.dart';
import '../models/transaction.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  sqflite.Database? _database;

  Future<sqflite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    final factory = getDatabaseFactory();
    String path = factory == sqflite.databaseFactory
        ? join(await sqflite.getDatabasesPath(), 'finance_manager.db')
        : 'finance_manager.db';

    return await factory.openDatabase(
      path,
      options: sqflite.OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        is_income INTEGER NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_income INTEGER NOT NULL
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _insertDefaultCategories(sqflite.Database db) async {
    final defaultCategories = [
      // Income categories
      {'name': 'Gaji', 'icon': 'wallet', 'color': '4CAF50', 'is_income': 1},
      {
        'name': 'Freelance',
        'icon': 'laptop',
        'color': '2196F3',
        'is_income': 1,
      },
      {
        'name': 'Investasi',
        'icon': 'trending-up',
        'color': 'FF9800',
        'is_income': 1,
      },

      // Expense categories
      {
        'name': 'Makanan',
        'icon': 'utensils',
        'color': 'F44336',
        'is_income': 0,
      },
      {
        'name': 'Transportasi',
        'icon': 'car',
        'color': '9C27B0',
        'is_income': 0,
      },
      {
        'name': 'Belanja',
        'icon': 'shopping-bag',
        'color': 'E91E63',
        'is_income': 0,
      },
      {
        'name': 'Hiburan',
        'icon': 'gamepad-2',
        'color': '3F51B5',
        'is_income': 0,
      },
      {'name': 'Kesehatan', 'icon': 'heart', 'color': 'FF5722', 'is_income': 0},
      {
        'name': 'Tagihan',
        'icon': 'file-text',
        'color': '795548',
        'is_income': 0,
      },
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category);
    }
  }

  // Transaction CRUD operations
  Future<int> insertTransaction(
    Transaction transaction,
  ) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<Transaction>> getTransactions({
    String? category,
    String? paymentMethod,
    bool? isIncome,
    DateTime? startDate,
    DateTime? endDate,
    String orderBy = 'date DESC',
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause += 'category = ?';
      whereArgs.add(category);
    }

    if (paymentMethod != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'payment_method = ?';
      whereArgs.add(paymentMethod);
    }

    if (isIncome != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'is_income = ?';
      whereArgs.add(isIncome ? 1 : 0);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date >= ?';
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date <= ?';
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
    );

    return List.generate(
      maps.length,
      (i) => Transaction.fromMap(maps[i]),
    );
  }

  Future<int> updateTransaction(
    Transaction transaction,
  ) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Category CRUD operations
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<Category>> getCategories({bool? isIncome}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: isIncome != null ? 'is_income = ?' : null,
      whereArgs: isIncome != null ? [isIncome ? 1 : 0] : null,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics
  Future<Map<String, double>> getMonthlyBalance(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      '''
      SELECT 
        SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) as expense
      FROM transactions 
      WHERE date >= ? AND date <= ?
    ''',
      [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch],
    );

    return {
      'income': (result.first['income'] as num?)?.toDouble() ?? 0.0,
      'expense': (result.first['expense'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
