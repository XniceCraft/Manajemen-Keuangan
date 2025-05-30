import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppTheme.textColor),
          displayMedium: TextStyle(color: AppTheme.textColor),
          displaySmall: TextStyle(color: AppTheme.textColor),
          headlineLarge: TextStyle(color: AppTheme.textColor),
          headlineMedium: TextStyle(color: AppTheme.textColor),
          headlineSmall: TextStyle(color: AppTheme.textColor),
          titleLarge: TextStyle(color: AppTheme.textColor),
          titleMedium: TextStyle(color: AppTheme.textColor),
          titleSmall: TextStyle(color: AppTheme.textColor),
          bodyLarge: TextStyle(color: AppTheme.textColor),
          bodyMedium: TextStyle(color: AppTheme.textColor),
          bodySmall: TextStyle(color: AppTheme.textSecondaryColor),
          labelLarge: TextStyle(color: AppTheme.textColor),
          labelMedium: TextStyle(color: AppTheme.textColor),
          labelSmall: TextStyle(color: AppTheme.textSecondaryColor),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
