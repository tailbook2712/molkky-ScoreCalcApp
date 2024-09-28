import 'package:flutter/material.dart';
import 'score_screen.dart';

class TeamNameScreen extends StatefulWidget {
  final int teamCount;
  final bool enableDisqualification;

  TeamNameScreen(
      {required this.teamCount, required this.enableDisqualification});

  @override
  _TeamNameScreenState createState() => _TeamNameScreenState();
}

class _TeamNameScreenState extends State<TeamNameScreen> {
  List<TextEditingController> _teamNameControllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.teamCount; i++) {
      _teamNameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (var controller in _teamNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToScoreScreen(BuildContext context) {
    List<String> teamNames =
        _teamNameControllers.map((controller) => controller.text).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          teamNames: teamNames,
          enableDisqualification: widget.enableDisqualification,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チーム名を決める', style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.teamCount,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _teamNameControllers[index],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'チーム ${index + 1} の名前',
                      ),
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToScoreScreen(context),
              child: Text('ゲーム開始', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}