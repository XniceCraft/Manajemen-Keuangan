import 'package:drift/drift.dart';
import '../database/database.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  AppDatabase? _database;

  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  // Transaction CRUD
  Future<int> insertTransaction(TransactionsCompanion transaction) async {
    final db = database;
    return await db.into(db.transactions).insert(transaction);
  }

  Future<List<Transaction>> getTransactions({
    String? category,
    String? paymentMethod,
    bool? isIncome,
    DateTime? startDate,
    DateTime? endDate,
    String orderBy = 'date DESC',
  }) async {
    final db = database;
    final query = db.select(db.transactions);
    if (category != null) {
      query.where((t) => t.category.equals(category));
    }
    if (paymentMethod != null) {
      query.where((t) => t.paymentMethod.equals(paymentMethod));
    }
    if (isIncome != null) {
      query.where((t) => t.isIncome.equals(isIncome));
    }
    if (startDate != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(endDate));
    }
    if (orderBy == 'date DESC') {
      query.orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    } else if (orderBy == 'date ASC') {
      query.orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc)]);
    }
    // Add more orderBy options as needed
    return await query.get();
  }

  Future<bool> updateTransaction(Transaction transaction) async {
    final db = database;
    return await db.update(db.transactions).replace(transaction);
  }

  Future<int> deleteTransaction(int id) async {
    final db = database;
    return await (db.delete(db.transactions)..where((t) => t.id.equals(id))).go();
  }

  // Category CRUD
  Future<int> insertCategory(CategoriesCompanion category) async {
    final db = database;
    return await db.into(db.categories).insert(category);
  }

  Future<List<Category>> getCategories({bool? isIncome}) async {
    final db = database;
    final query = db.select(db.categories);
    if (isIncome != null) {
      query.where((c) => c.isIncome.equals(isIncome));
    }
    query.orderBy([(c) => OrderingTerm(expression: c.name)]);
    return await query.get();
  }

  Future<bool> updateCategory(Category category) async {
    final db = database;
    return await db.update(db.categories).replace(category);
  }

  Future<int> deleteCategory(int id) async {
    final db = database;
    return await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  }

  // Statistics
  Future<Map<String, double>> getMonthlyBalance(DateTime month) async {
    final db = database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final income = await (db.select(db.transactions)
      ..where((t) => t.isIncome.equals(true) & t.date.isBiggerOrEqualValue(startOfMonth) & t.date.isSmallerOrEqualValue(endOfMonth)))
      .get();
    final expense = await (db.select(db.transactions)
      ..where((t) => t.isIncome.equals(false) & t.date.isBiggerOrEqualValue(startOfMonth) & t.date.isSmallerOrEqualValue(endOfMonth)))
      .get();
    final incomeSum = income.fold<double>(0, (sum, t) => sum + t.amount);
    final expenseSum = expense.fold<double>(0, (sum, t) => sum + t.amount);
    return {'income': incomeSum, 'expense': expenseSum};
  }

  // Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}