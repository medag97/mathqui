import 'package:flutter/material.dart';
import 'package:mathquiz/screens/GamePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String selectedDifficulty = 'Easy';
  int highestScore = 0;
  String highScoreUser = '';

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestScore = prefs.getInt('highest_score') ?? 0;
      highScoreUser = prefs.getString('high_score_user') ?? '';
    });
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highest_score', score);
    await prefs.setString('high_score_user', userName);
    _loadHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Game Difficulty',
              style: TextStyle(fontSize: 18),
            ),
            ListTile(
              title: const Text('Easy'),
              leading: Radio<String>(
                value: 'Easy',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Medium'),
              leading: Radio<String>(
                value: 'Medium',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Hard'),
              leading: Radio<String>(
                value: 'Hard',
                groupValue: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Highest Score: $highestScore by $highScoreUser',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: userName.isNotEmpty ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GamePage(
                        difficulty: selectedDifficulty == 'Easy' ? Difficulty.Easy :
                                    selectedDifficulty == 'Medium' ? Difficulty.Medium : Difficulty.Hard,
                        onGameFinished: (score) {
                          if (score > highestScore) {
                            _saveHighScore(score);
                          }
                        },
                      ),
                    ),
                  );
                } : null,
                child: Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
