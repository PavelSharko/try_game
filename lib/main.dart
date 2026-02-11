import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const AliasGameApp());
}

class AliasGameApp extends StatelessWidget {
  const AliasGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alias Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE), // Vibrant Purple
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}
