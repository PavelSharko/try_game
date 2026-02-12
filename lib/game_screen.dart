import 'dart:async'; // New: Async for Timer
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game State
  int _score = 0;
  late int _currentCardValue;
  late String _currentCardSuit;
  // New: Next Card State
  late int _nextCardValue;
  late String _nextCardSuit;
  
  String _trumpSuit = ''; // New: Trump Suit State
  bool _isGameOver = false;
  
  // New: Timer State
  Timer? _timer;
  int _timeLeft = 60;
  String _gameOverMessage = '';

  final Random _random = Random();
  // New: Restricted suits (Bubny, Piki, Kresti)
  final List<String> _suits = ['Бубны', 'Пики', 'Крести'];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Prevent memory leaks
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel(); // Cancel existing timer
    setState(() {
      _score = 0;
      _isGameOver = false;
      _timeLeft = 60; // Reset timer
      _gameOverMessage = '';
      
      // New: Select random trump
      _trumpSuit = _suits[_random.nextInt(_suits.length)];
      _generateCurrentCard();
      _generateNextCard();
      
      // Start Timer
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        // Time is up!
        _timer?.cancel();
        setState(() {
          _isGameOver = true;
          _gameOverMessage = 'Время вышло!';
        });
      }
    });
  }

  void _generateCurrentCard() {
    _currentCardValue = _random.nextInt(13) + 2; // 2 to 14
    _currentCardSuit = _suits[_random.nextInt(_suits.length)];
  }

  void _generateNextCard() {
    _nextCardValue = _random.nextInt(13) + 2; // 2 to 14
    _nextCardSuit = _suits[_random.nextInt(_suits.length)];
  }

  String _getCardName(int value, String suit) {
    String valueStr;
    switch (value) {
      case 11:
        valueStr = 'Валет';
        break;
      case 12:
        valueStr = 'Дама';
        break;
      case 13:
        valueStr = 'Король';
        break;
      case 14:
        valueStr = 'Туз';
        break;
      default:
        valueStr = value.toString();
    }
    return '$valueStr $suit';
  }

  void _handleGuess(bool isHigher) {
    // Logic: Compare NEXT (state) vs CURRENT (state)
    bool nextIsTrump = _nextCardSuit == _trumpSuit;
    bool currentIsTrump = _currentCardSuit == _trumpSuit;
    
    bool isNextActuallyHigher = false;
    bool isEqual = false;

    if (nextIsTrump && !currentIsTrump) {
      // Trump is always higher than non-trump
      isNextActuallyHigher = true;
    } else if (!nextIsTrump && currentIsTrump) {
      // Non-trump is always lower than trump
      isNextActuallyHigher = false;
    } else {
      // Both are trump OR Both are non-trump -> Compare values
      if (_nextCardValue > _currentCardValue) {
        isNextActuallyHigher = true;
      } else if (_nextCardValue == _currentCardValue) {
        isEqual = true;
      }
    }

    bool isCorrect = false;
    if (isEqual) {
      isCorrect = true; // Equal counts as correct
    } else if (isHigher && isNextActuallyHigher) {
      isCorrect = true;
    } else if (!isHigher && !isNextActuallyHigher) {
      isCorrect = true;
    }

    setState(() {
      if (isCorrect) {
        // New: Bonus Logic - +10 only if BOTH are Trump
        if (_currentCardSuit == _trumpSuit && _nextCardSuit == _trumpSuit) {
             _score += 10;
        } else {
             _score++;
        }
        
        // Move Next to Current
        _currentCardValue = _nextCardValue;
        _currentCardSuit = _nextCardSuit;
        
        // Generate NEW Next
        _generateNextCard();
      } else {
        _isGameOver = true;
        _gameOverMessage = 'Неверно!';
        _timer?.cancel(); // Stop timer on loss
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            const Text(
              'Карточный Пророк',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 10),
            
            // New: Timer Display
            Text(
              'Время: $_timeLeft',
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: _timeLeft <= 10 ? Colors.red : Colors.black, // Red warning
              ),
            ),
            const SizedBox(height: 10),
            
            // New: Trump Display
            Text(
              'Козырь: $_trumpSuit',
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.redAccent
              ),
            ),
            const SizedBox(height: 20),

            if (_isGameOver) ...[
               Text(
                'Игра Окончена! $_gameOverMessage',
                style: const TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
               Text(
                'Итоговый счет: $_score',
                style: const TextStyle(fontSize: 24, color: Colors.black54),
              ),
              const SizedBox(height: 30),
             
              ElevatedButton(
                onPressed: _startNewGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('НОВАЯ ИГРА'),
              ),
            ] else ...[
              // Score
              Text(
                'Счет: $_score',
                style: const TextStyle(fontSize: 24, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Current Card Display
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _getCardName(_currentCardValue, _currentCardSuit),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),

              // Input Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GameButton(
                    label: '[МЕНЬШЕ]',
                    onPressed: () => _handleGuess(false),
                  ),
                  const SizedBox(width: 20),
                  _GameButton(
                    label: '[БОЛЬШЕ]',
                    onPressed: () => _handleGuess(true),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // New: Cheat Display (Next Card)
              Text(
                'Следующая карта будет: ${_getCardName(_nextCardValue, _nextCardSuit)}',
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GameButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Square corners
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
