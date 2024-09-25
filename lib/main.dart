import 'package:flutter/material.dart';

void main() => runApp(const MolkkyApp());

class MolkkyApp extends StatelessWidget {
  const MolkkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mölkky Score App',
      home: TeamSelectionScreen(),
    );
  }
}

// チーム人数をテキスト入力で選択する画面
class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final TextEditingController _teamCountController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _teamCountController.dispose();
    super.dispose();
  }

  void _navigateToScoreScreen(BuildContext context) {
    int? teamCount = int.tryParse(_teamCountController.text);
    if (teamCount != null && teamCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(teamCount: teamCount),
        ),
      );
    } else {
      setState(() {
        _errorMessage = '有効なチーム数を入力してください (1以上の整数)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チーム人数を選択', style: TextStyle(fontSize: 24)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('何チームで遊びますか？', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _teamCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'チーム数を入力',
                ),
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToScoreScreen(context),
                child: const Text('次へ', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 得点計算の画面
class ScoreScreen extends StatefulWidget {
  final int teamCount; // チームの人数を受け取る

  const ScoreScreen({super.key, required this.teamCount});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    for (int i = 1; i <= widget.teamCount; i++) {
      players.add(Player(name: 'チーム $i', score: 0));
    }
  }

  // スコアを更新するメソッド
  void _updateScore(int index, int score) {
    setState(() {
      players[index].score += score;
    });
    Navigator.of(context).pop();
    _checkForWinner(players[index]);
  }

  // 勝利チームのダイアログを表示
  Future<void> _showWinnerDialog(String winnerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('勝利！', style: TextStyle(fontSize: 24)),
          content: Text('$winnerName が50点に達しました！',
              style: const TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // スコアが50に達したかどうかを確認，50を超えた場合は25にリセット
  void _checkForWinner(Player player) {
    if (player.score == 50) {
      _showWinnerDialog(player.name);
    } else if (player.score > 50) {
      setState(() {
        player.score = 25;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Mölkky Score Tracker', style: TextStyle(fontSize: 24)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    players[index].name,
                    style: const TextStyle(fontSize: 24),
                  ),
                  trailing: Text(
                    players[index].score.toString(),
                    style: const TextStyle(fontSize: 24),
                  ),
                  onTap: () => _showScoreDialog(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // スコアを入力するダイアログを表示
  void _showScoreDialog(int playerIndex) {
    int score = 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('得点を更新', style: TextStyle(fontSize: 24)),
          content: TextField(
            onChanged: (value) {
              score = int.tryParse(value) ?? 0;
            },
            decoration: const InputDecoration(hintText: '得点'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateScore(playerIndex, score);
              },
              child: const Text('更新', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }
}

class Player {
  final String name;
  int score;

  Player({required this.name, required this.score});
}
