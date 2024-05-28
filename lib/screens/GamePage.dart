import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mathquiz/screens/score_page.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Difficulty { Easy, Medium, Hard }

class GamePage extends StatefulWidget {
  final Difficulty difficulty;
  final void Function(int) onGameFinished;

  GamePage({required this.difficulty, required this.onGameFinished});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int num1 = 0;
  int num2 = 0;
  int displayedSum = 0;
  int correctSum = 0;
  bool isCorrectSum = true;
  int score = 0;
  int highestScore = 0;
  bool buttonsEnabled = true;
  bool isPaused = false;
  late SharedPreferences prefs;
  late Stopwatch stopwatch;
  late int timerDuration;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((preferences) {
      prefs = preferences;
      loadHighestScore();
    });
    stopwatch = Stopwatch();
    setTimerDuration();
    generateEquation();
    startTimer();
  }

  void loadHighestScore() {
    final int? savedScore = prefs.getInt('highest_score');
    if (savedScore != null) {
      setState(() {
        highestScore = savedScore;
      });
    }
  }

  void saveHighestScore(int newScore) async {
    await prefs.setInt('highest_score', newScore);
  }

  void setTimerDuration() {
    switch (widget.difficulty) {
      case Difficulty.Easy:
        timerDuration = 30;
        break;
      case Difficulty.Medium:
        timerDuration = 20;
        break;
      case Difficulty.Hard:
        timerDuration = 10;
        break;
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (timerDuration > 0) {
            timerDuration--;
          } else {
            timer.cancel();
            handleGameOver();
          }
        });
      }
    });
  }

  void generateEquation() {
    if (!isPaused) {
      setState(() {
        num1 = Random().nextInt(99) + 1;
        num2 = Random().nextInt(99) + 1;
        correctSum = num1 + num2;
        isCorrectSum = Random().nextBool();

        if (isCorrectSum) {
          displayedSum = correctSum;
        } else {
          displayedSum = correctSum + Random().nextInt(20) - 10;
          while (displayedSum == correctSum) {
            displayedSum = correctSum + Random().nextInt(20) - 10;
          }
        }
      });
    }
  }

  void checkAnswer(bool isCorrect) {
    if ((isCorrect && isCorrectSum) || (!isCorrect && !isCorrectSum)) {
      setState(() {
        score += 10;
      });
      generateEquation();
    } else {
      handleGameOver();
    }
  }

  void handleGameOver() {
    if (!buttonsEnabled) return;
    stopwatch.stop();
    setState(() {
      buttonsEnabled = false;
    });
    Fluttertoast.showToast(msg: "Incorrect! Game Over.");
    Vibration.vibrate(duration: 500);
    if (score > highestScore) {
      saveHighestScore(score);
      highestScore = score;
    }
    widget.onGameFinished(score);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScorePage(score: score, difficulty: difficultyToString(widget.difficulty), onGameFinished: widget.onGameFinished),
      ),
    );
  }

  String difficultyToString(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.Easy:
        return 'Easy';
      case Difficulty.Medium:
        return 'Medium';
      case Difficulty.Hard:
        return 'Hard';
      default:
        return '';
    }
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Page'),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: togglePause,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$num1 + $num2 = $displayedSum',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: buttonsEnabled && !isPaused ? () => checkAnswer(true) : null,
                    child: Text('Correct'),
                  ),
                  ElevatedButton(
                    onPressed: buttonsEnabled && !isPaused ? () => checkAnswer(false) : null,
                    child: Text('Incorrect'),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                'Time Remaining: $timerDuration seconds',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              Text(
                'Score: $score',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
