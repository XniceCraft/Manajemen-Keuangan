import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get category => text()();
  TextColumn get paymentMethod => text().named('payment_method')();
  BoolColumn get isIncome => boolean().named('is_income')();
  TextColumn get description => text().nullable()();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  BoolColumn get isIncome => boolean().named('is_income')();
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'finance_management',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _insertDefaultCategories();
      },
    );
  }

  Future<void> _insertDefaultCategories() async {
    final defaultCategories = [
      CategoriesCompanion.insert(
        name: 'Gaji',
        icon: 'wallet',
        color: '4CAF50',
        isIncome: true,
      ),
      CategoriesCompanion.insert(
        name: 'Freelance',
        icon: 'laptop',
        color: '2196F3',
        isIncome: true,
      ),
      CategoriesCompanion.insert(
        name: 'Investasi',
        icon: 'trending-up',
        color: 'FF9800',
        isIncome: true,
      ),
      // Expense categories
      CategoriesCompanion.insert(
        name: 'Makanan',
        icon: 'utensils',
        color: 'F44336',
        isIncome: false,
      ),
      CategoriesCompanion.insert(
        name: 'Transportasi',
        icon: 'car',
        color: '9C27B0',
        isIncome: false,
      ),
      CategoriesCompanion.insert(
        name: 'Belanja',
        icon: 'shopping-bag',
        color: 'E91E63',
        isIncome: false,
      ),
      CategoriesCompanion.insert(
        name: 'Hiburan',
        icon: 'gamepad-2',
        color: '3F51B5',
        isIncome: false,
      ),
      CategoriesCompanion.insert(
        name: 'Kesehatan',
        icon: 'heart',
        color: 'FF5722',
        isIncome: false,
      ),
      CategoriesCompanion.insert(
        name: 'Tagihan',
        icon: 'file-text',
        color: '795548',
        isIncome: false,
      ),
    ];

    for (var category in defaultCategories) {
      await into(categories).insert(category);
    }
  }
}
