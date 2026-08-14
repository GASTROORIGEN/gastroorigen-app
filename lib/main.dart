import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GastroOrigenApp());
}

class GastroOrigenApp extends StatelessWidget {
  const GastroOrigenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GASTROORIGEN',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A3E24),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F0E6),
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
