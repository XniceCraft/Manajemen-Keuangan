import '../database/database.dart';
import '../services/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  return TransactionsNotifier(ref.read(databaseProvider));
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return CategoriesNotifier(ref.read(databaseProvider));
});

final balanceProvider = StateNotifierProvider<BalanceNotifier, AsyncValue<Map<String, double>>>((ref) {
  return BalanceNotifier(ref.read(databaseProvider));
});

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final DatabaseHelper _db;

  TransactionsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  Future<void> loadTransactions({
    String? category,
    String? paymentMethod,
    bool? isIncome,
    DateTime? startDate,
    DateTime? endDate,
    String orderBy = 'date DESC',
  }) async {
    try {
      state = const AsyncValue.loading();
      final transactions = await _db.getTransactions(
        category: category,
        paymentMethod: paymentMethod,
        isIncome: isIncome,
        startDate: startDate,
        endDate: endDate,
        orderBy: orderBy,
      );
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addTransaction(TransactionsCompanion transaction) async {
    try {
      await _db.insertTransaction(transaction);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _db.deleteTransaction(id);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final DatabaseHelper _db;

  CategoriesNotifier(this._db) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories({bool? isIncome}) async {
    try {
      state = const AsyncValue.loading();
      final categories = await _db.getCategories(isIncome: isIncome);
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCategory(CategoriesCompanion category) async {
    try {
      await _db.insertCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _db.updateCategory(category);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _db.deleteCategory(id);
      await loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class BalanceNotifier extends StateNotifier<AsyncValue<Map<String, double>>> {
  final DatabaseHelper _db;

  BalanceNotifier(this._db) : super(const AsyncValue.loading()) {
    loadMonthlyBalance(DateTime.now());
  }

  Future<void> loadMonthlyBalance(DateTime month) async {
    try {
      state = const AsyncValue.loading();
      final balance = await _db.getMonthlyBalance(month);
      state = AsyncValue.data(balance);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}