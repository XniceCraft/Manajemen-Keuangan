import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/add_category_screen.dart';
import '../screens/statistics_screen.dart';
import '../database/database.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
    ),
    GoRoute(
      path: '/add-transaction',
      pageBuilder: (context, state) {
        final transaction = state.extra as Transaction?;
        return NoTransitionPage(child: AddTransactionScreen(transaction: transaction));
      },
    ),
    GoRoute(
      path: '/transactions',
      pageBuilder: (context, state) => const NoTransitionPage(child: TransactionsScreen()),
    ),
    GoRoute(
      path: '/categories',
      pageBuilder: (context, state) => const NoTransitionPage(child: CategoriesScreen()),
    ),
    GoRoute(
      path: '/add-category',
      pageBuilder: (context, state) {
        final category = state.extra as Category?;
        return NoTransitionPage(child: AddCategoryScreen(category: category));
      },
    ),
    GoRoute(
      path: '/statistics',
      pageBuilder: (context, state) => const NoTransitionPage(child: StatisticsScreen()),
    ),
  ],
);