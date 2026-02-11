import 'dart:async';
import 'package:flutter/material.dart';

// 1. Model for Animal
class Animal {
  final String name;
  final String sound;
  final IconData icon;
  final Color color;

  const Animal({
    required this.name,
    required this.sound,
    required this.icon,
    required this.color,
  });
}

// 2. Data: List of available animals
const List<Animal> availableAnimals = [
  Animal(name: 'Собака', sound: 'ГАВ!', icon: Icons.pets, color: Colors.orange),
  Animal(name: 'Кот', sound: 'МЯУ!', icon: Icons.cruelty_free, color: Colors.blue),
  Animal(name: 'Корова', sound: 'МУ-У!', icon: Icons.grass, color: Colors.green),
  Animal(name: 'Овца', sound: 'БЕ-Е!', icon: Icons.waves, color: Colors.lightGreen),
  Animal(name: 'Лошадь', sound: 'ИГО-ГО!', icon: Icons.bedroom_baby, color: Colors.brown),
  Animal(name: 'Свинья', sound: 'ХРЮ!', icon: Icons.savings, color: Colors.pink),
  Animal(name: 'Петух', sound: 'КУ-КА-РЕ-КУ!', icon: Icons.wb_sunny, color: Colors.red),
  Animal(name: 'Утка', sound: 'КРЯ!', icon: Icons.water, color: Colors.teal),
  Animal(name: 'Лев', sound: 'Р-Р-Р!', icon: Icons.emoji_nature, color: Colors.amber),
  Animal(name: 'Обезьяна', sound: 'У-У-А-А!', icon: Icons.emoji_people, color: Colors.purple),
];

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // State: Currently selected animals
  Animal _leftAnimal = availableAnimals[0]; // Dog
  Animal _rightAnimal = availableAnimals[1]; // Cat

  // Animation State
  String _displayMessage = '';
  Color _messageColor = Colors.white;
  Timer? _timer;

  void _playSound(String sound, Color color) {
    _timer?.cancel();
    setState(() {
      _displayMessage = sound;
      _messageColor = color;
    });

    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _displayMessage = '';
        });
      }
    });
  }

  // Logic to show selection menu
  void _showAnimalSelection(bool isLeft) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Выберите животное для ${isLeft ? "левой" : "правой"} кнопки',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: availableAnimals.length,
                  itemBuilder: (context, index) {
                    final animal = availableAnimals[index];
                    return ListTile(
                      leading: Icon(animal.icon, color: animal.color, size: 32),
                      title: Text(animal.name, style: const TextStyle(fontSize: 18)),
                      subtitle: Text(animal.sound),
                      onTap: () {
                        setState(() {
                          if (isLeft) {
                            _leftAnimal = animal;
                          } else {
                            _rightAnimal = animal;
                          }
                        });
                        Navigator.pop(context); // Close menu
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0249),
              Color(0xFF570A57),
            ],
          ),
        ),
        child: SafeArea( // Ensure UI doesn't overlap system bars
          child: Column(
            children: [
              // 1. Feedback Area (Top)
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _displayMessage.isNotEmpty ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 100),
                    child: Text(
                      _displayMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 64, // Bigger text
                        fontWeight: FontWeight.w900,
                        color: _messageColor,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2. Main Game Area (Center Buttons)
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // LEFT BUTTON
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _AnimalGameButton(
                          animal: _leftAnimal,
                          onPressed: () => _playSound(_leftAnimal.sound, _leftAnimal.color),
                          onLongPress: () => _showAnimalSelection(true), // Long press to change
                        ),
                      ),
                    ),
                    // RIGHT BUTTON
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _AnimalGameButton(
                          animal: _rightAnimal,
                          onPressed: () => _playSound(_rightAnimal.sound, _rightAnimal.color),
                          onLongPress: () => _showAnimalSelection(false), // Long press to change
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Helper Hint / Quick Menu (Bottom)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      "Нажмите, чтобы услышать звук\nУдерживайте, чтобы сменить животное",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    // Quick Swap Buttons (Visual cue)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAnimalSelection(true),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Левый"),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showAnimalSelection(false),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Правый"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimalGameButton extends StatelessWidget {
  final Animal animal;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const _AnimalGameButton({
    required this.animal,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: animal.color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          padding: EdgeInsets.zero, // Use Container for padding
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(animal.icon, size: 64),
              const SizedBox(height: 16),
              Text(
                animal.name.toUpperCase(),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
