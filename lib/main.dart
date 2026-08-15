import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const GastroOrigenApp());
}

class GastroOrigenApp extends StatelessWidget {
  const GastroOrigenApp({super.key});

  @override
  Widget build(BuildContext context) {
    const forest = Color(0xFF00452F);
    const chile = Color(0xFFA62C18);
    const gold = Color(0xFFD59A1C);
    const cream = Color(0xFFFBF4E7);
    const surface = Color(0xFFFFFDF8);
    const text = Color(0xFF17251F);
    const line = Color(0xFFD9B86A);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GASTROORIGEN',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        fontFamily: 'sans-serif',
        colorScheme: const ColorScheme.light(
          primary: forest,
          onPrimary: Colors.white,
          secondary: chile,
          onSecondary: Colors.white,
          tertiary: gold,
          onTertiary: text,
          surface: surface,
          onSurface: text,
          outline: line,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: forest,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFEAD8A8)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: forest,
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: chile,
            side: const BorderSide(color: chile, width: 1.5),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: forest,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
