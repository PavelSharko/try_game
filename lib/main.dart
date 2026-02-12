import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const CardProphetApp());
}

class CardProphetApp extends StatelessWidget {
  const CardProphetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Карточный Пророк',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        fontFamily: 'Courier New', // Monospace for minimalist feel
      ),
      home: const GameScreen(),
    );
  }
}
