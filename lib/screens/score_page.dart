import 'package:flutter/material.dart';
import 'package:mathquiz/screens/GamePage.dart'; // Make sure this import is correct

class ScorePage extends StatelessWidget {
  final int score;
  final String difficulty;
  final void Function(int) onGameFinished;

  ScorePage({required this.score, required this.difficulty, required this.onGameFinished});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Score: $score',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle what should happen when a game is finished after replay
                  // Typically this might involve clearing states, resetting scores, etc.
                  onGameFinished(score);

                  // Navigate back to GamePage using the existing difficulty setting
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(
                        difficulty: stringToDifficulty(difficulty),
                        onGameFinished: onGameFinished,
                      ),
                    ),
                  );
                },
                child: Text('Replay'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: Text('New Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Difficulty stringToDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Difficulty.Easy;
      case 'Medium':
        return Difficulty.Medium;
      case 'Hard':
        return Difficulty.Hard;
      default:
        return Difficulty.Easy; // Default to Easy if something goes wrong
    }
  }
}
