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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-transaction',
      builder: (context, state) {
        final transaction = state.extra as Transaction?;
        return AddTransactionScreen(transaction: transaction);
      },
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesScreen(),
    ),
    GoRoute(
      path: '/add-category',
      builder: (context, state) => const AddCategoryScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
  ],
);