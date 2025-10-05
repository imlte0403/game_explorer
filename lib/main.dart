import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:game_explorer/core/router/app_router.dart';
import 'package:game_explorer/core/constants/colors.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Game Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.steamDarkBlue,
        colorScheme: ColorScheme.dark(
          primary: AppColors.steamAccent,
          secondary: AppColors.steamBlue,
          surface: AppColors.steamBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.steamDarkBlue,
          foregroundColor: AppColors.steamWhite,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.steamBlue,
          selectedItemColor: AppColors.steamAccent,
          unselectedItemColor: AppColors.steamGrey,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.steamBlue,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.steamWhite),
          bodyMedium: TextStyle(color: AppColors.steamWhite),
          bodySmall: TextStyle(color: AppColors.steamGrey),
        ),
      ),
      routerConfig: goRouter,
    );
  }
}
