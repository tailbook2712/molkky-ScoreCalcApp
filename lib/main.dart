import 'package:flutter/material.dart';

void main() => runApp(MolkkyApp());

class MolkkyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mölkky Score App',
      home: TeamSelectionScreen(), // 最初の画面をチーム選択画面に設定
    );
  }
}

// チーム人数をテキスト入力で選択する画面
class TeamSelectionScreen extends StatefulWidget {
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

  void _navigateToTeamNameScreen(BuildContext context) {
    int? teamCount = int.tryParse(_teamCountController.text);
    if (teamCount != null && teamCount > 0) {
      // チーム人数が入力されたら、チーム名入力画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamNameScreen(teamCount: teamCount),
        ),
      );
    } else {
      // 入力が無効の場合、エラーメッセージを表示
      setState(() {
        _errorMessage = '有効なチーム数を入力してください (1以上の整数)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チーム人数を選択', style: TextStyle(fontSize: 24)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('何チームで遊びますか？', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              TextField(
                controller: _teamCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'チーム数を入力',
                ),
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 10),
              // エラーメッセージの表示
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToTeamNameScreen(context),
                child: Text('次へ', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// チーム名を入力する画面
class TeamNameScreen extends StatefulWidget {
  final int teamCount;

  TeamNameScreen({required this.teamCount});

  @override
  _TeamNameScreenState createState() => _TeamNameScreenState();
}

class _TeamNameScreenState extends State<TeamNameScreen> {
  List<TextEditingController> _teamNameControllers = [];

  @override
  void initState() {
    super.initState();
    // チーム人数分のテキストコントローラを作成
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
        builder: (context) => ScoreScreen(teamNames: teamNames),
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

// 得点計算の画面
class ScoreScreen extends StatefulWidget {
  final List<String> teamNames;

  ScoreScreen({required this.teamNames});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<Player> players = [];

  @override
  void initState() {
    super.initState();
    // チーム名に基づいてプレイヤーリストを初期化
    _resetScores();
  }

  // 得点をリセットして再試合を始める
  void _resetScores() {
    setState(() {
      players = widget.teamNames
          .map((name) => Player(
              teamName: name,
              score: 0,
              zeroScoreCount: 0,
              isDisqualified: false))
          .toList();
    });
  }

  // スコアを更新するメソッド
  void _updateScore(int index, int score) {
    setState(() {
      if (players[index].isDisqualified) {
        // 失格したチームはスコア更新できない
        return;
      }

      if (score == 0) {
        players[index].zeroScoreCount += 1;
        if (players[index].zeroScoreCount >= 3) {
          // 3回連続でゼロの場合、失格にする
          players[index].isDisqualified = true;
          return;  // 失格後はスコアの更新を行わない
        }
      } else {
        players[index].zeroScoreCount = 0;  // ゼロ以外の得点を取ったらリセット
      }

      players[index].score += score;
    });

    // ダイアログを閉じる
    Navigator.of(context).pop();

    // 勝利条件の確認
    _checkForWinner(players[index]);
  }

  // 勝利チームのダイアログを表示
  Future<void> _showWinnerDialog(String winnerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // ユーザーが他の場所をタップしても閉じられないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('勝利！', style: TextStyle(fontSize: 24)),
          content:
              Text('$winnerName が50点に達しました！', style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).popUntil(
                    (route) => route.isFirst); // TeamSelectionScreenに戻る
              },
              child: Text('終了', style: TextStyle(fontSize: 24)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                _resetScores(); // スコアをリセットして再試合
              },
              child: Text('もう一度', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // 失格チームのダイアログを表示
  Future<void> _showDisqualificationDialog(String teamName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失格', style: TextStyle(fontSize: 24)),
          content: Text('$teamName は3回連続でゼロ点を記録したため失格です．', style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // スコアが50に達したかどうかを確認
  void _checkForWinner(Player player) {
    if (player.score == 50) {
      _showWinnerDialog(player.teamName);
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
        title: Text('Mölkky Score Tracker', style: TextStyle(fontSize: 24)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    players[index].teamName,
                    style: TextStyle(fontSize: 24),
                  ),
                  trailing: Text(
                    players[index].isDisqualified 
                      ? '失格' 
                      :players[index].score.toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                  onTap: () => players[index].isDisqualified
                    ? null
                    : _showScoreDialog(index),  // 失格したチームはスコア入力できない
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
    if (players[playerIndex].isDisqualified) return;  // 失格したチームはダイアログを開かない
    int score = 0;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('得点を更新', style: TextStyle(fontSize: 24)),
          content: TextField(
            onChanged: (value) {
              score = int.tryParse(value) ?? 0;
            },
            decoration: InputDecoration(hintText: '得点'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateScore(playerIndex, score); // スコアを更新してダイアログを閉じる
              },
              child: Text('更新', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }
}

class Player {
  final String teamName; // チーム名
  int score; // 得点
  int zeroScoreCount; // 連続でゼロ点をとった回数のカウント
  bool isDisqualified; // 失格のフラグ

  Player(
      {required this.teamName,
      required this.score,
      required this.zeroScoreCount,
      required this.isDisqualified});
}
