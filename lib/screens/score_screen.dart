import 'package:flutter/material.dart';
import '../models/player.dart';
import 'team_selection_screen.dart';

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
    _resetScores();
  }

  // 得点をリセットして再試合を始める
  void _resetScores() {
    setState(() {
      players = widget.teamNames.map((name) => Player(name: name, score: 0, zeroScoreStreak: 0, isDisqualified: false)).toList();
    });
  }

  // スコアを更新するメソッド
  void _updateScore(int index, int score) async {
    setState(() {
      if (players[index].isDisqualified) return;

      if (score == 0) {
        players[index].zeroScoreStreak += 1;
      } else {
        players[index].zeroScoreStreak = 0;  // ゼロ以外の得点を取ったらリセット
      }

      players[index].score += score;
    });

    // ダイアログを閉じる
    Navigator.of(context).pop();

    // 失格の判定を得点の更新後に行う
    _checkForDisqualification(index);
    
    // 勝利条件の確認
    _checkForWinner(players[index]);
  }

  // 失格をチェックするメソッド
  void _checkForDisqualification(int index) {
    if (players[index].zeroScoreStreak >= 3) {
      setState(() {
        players[index].isDisqualified = true;
      });

      // チーム数が1の場合
      if (players.length == 1) {
        _showSinglePlayerDisqualificationDialog(players[index].name);
      } 
      // チーム数が2の場合
      else if (players.length == 2) {
        int otherPlayerIndex = (index == 0) ? 1 : 0;
        _showWinnerDialog(players[otherPlayerIndex].name);
      } 
      // チーム数が3以上の場合
      else {
        int remainingPlayers = players.where((p) => !p.isDisqualified).length;
        if (remainingPlayers == 1) {
          // 最後の1チームが残っていれば勝利ダイアログを表示
          Player remainingPlayer = players.firstWhere((p) => !p.isDisqualified);
          _showWinnerDialog(remainingPlayer.name);
        } else {
          // まだ複数のチームが残っている場合は失格ダイアログを表示
          _showDisqualificationDialog(players[index].name);
        }
      }
    }
  }

  // チームが1の場合の失格ダイアログ
  Future<void> _showSinglePlayerDisqualificationDialog(String playerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失格！', style: TextStyle(fontSize: 24)),
          content: Text('$playerName は3回連続でゼロ得点を記録したため失格です。', style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst); // TeamSelectionScreenに戻る
              },
              child: Text('OK', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // チームが2の場合の勝利ダイアログ
  Future<void> _showWinnerDialog(String winnerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('勝利！', style: TextStyle(fontSize: 24)),
          content: Text('$winnerName が勝利しました！', style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScores();
              },
              child: Text('もう一度', style: TextStyle(fontSize: 24)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('チーム人数選択へ戻る', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // チームが3以上の場合の失格ダイアログ
  Future<void> _showDisqualificationDialog(String playerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失格！', style: TextStyle(fontSize: 24)),
          content: Text('$playerName は3回連続でゼロ得点を記録したため失格です。', style: TextStyle(fontSize: 24)),
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
                    players[index].name,
                    style: TextStyle(fontSize: 24),
                  ),
                  trailing: Text(
                    players[index].isDisqualified
                        ? '失格'
                        : players[index].score.toString(),
                    style: TextStyle(fontSize: 24),
                  ),
                  onTap: players[index].isDisqualified
                      ? null
                      : () => _showScoreDialog(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showScoreDialog(int playerIndex) {
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
                _updateScore(playerIndex, score);
              },
              child: Text('更新', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }
}