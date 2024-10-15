import 'package:flutter/material.dart';
import 'package:mollky_score_app/models/score_history.dart';
import '../models/player.dart';
import 'package:mollky_score_app/models/history_manager.dart';
import 'package:intl/intl.dart';

class ScoreScreen extends StatefulWidget {
  final List<String> teamNames;
  final bool enableDisqualification; // 失格機能の状態を受け取る

  ScoreScreen({required this.teamNames, required this.enableDisqualification});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  List<Player> players = [];
  List<ScoreHistory> scoreHistories = [];

  @override
  void initState() {
    super.initState();
    _resetScores();
  }

  // 得点をリセットして再試合を始める
  void _resetScores() {
    setState(() {
      players = widget.teamNames
          .map((name) => Player(
              name: name, score: 0, zeroScoreStreak: 0, isDisqualified: false))
          .toList();
      scoreHistories = widget.teamNames
          .map((name) => ScoreHistory(playerName: name))
          .toList();
    });
  }

  // スコアを更新するメソッド
  void _updateScore(int index, int score) async {
    setState(() {
      if (players[index].isDisqualified) return;

      if (score == 0) {
        players[index].zeroScoreStreak += 1;
      } else {
        players[index].zeroScoreStreak = 0; // ゼロ以外の得点を取ったらリセット
      }

      players[index].score += score;
      scoreHistories[index].scores.add(score); // スコア履歴に追加
    });

    // ダイアログを閉じる
    Navigator.of(context).pop();

    // 失格機能が有効な場合のみ失格の判定を行う
    if (widget.enableDisqualification) {
      _checkForDisqualification(index);
    }

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
  Future<void> _showSinglePlayerDisqualificationDialog(
      String playerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失格！', style: TextStyle(fontSize: 24)),
          content: Text('$playerName は3回連続でゼロ得点を記録したため失格です。',
              style: TextStyle(fontSize: 24)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil(
                    (route) => route.isFirst); // TeamSelectionScreenに戻る
              },
              child: Text('OK', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // ゲームが終了した時に履歴を保存
  void _saveGameHistory() async {
    List<Map<String, dynamic>> playerData = players.map((player) {
      return {
        'name': player.name,
        'score': player.score,
        'scores': scoreHistories.firstWhere((history) => history.playerName == player.name).scores,  // 各プレイヤーのスコア履歴を追加
      };
    }).toList();

    String formattedDate = DateFormat('yyyy/MM/dd').format(DateTime.now());

    Map<String, dynamic> gameData = {
      'players': playerData,
      'date': formattedDate,
    };

    await HistoryManager.saveGameHistory(gameData);
    // デバッグ: 保存された履歴を確認
    List history = await HistoryManager.getGameHistory();
    print('現在の履歴: $history');
  }

  // チームが2の場合の勝利ダイアログ
  Future<void> _showWinnerDialog(String winnerName) async {
    _saveGameHistory();
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
              child: Text('ゲームモード選択に戻る', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
    // _saveGameHistory();
  }

  // チームが3以上の場合の失格ダイアログ
  Future<void> _showDisqualificationDialog(String playerName) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('失格！', style: TextStyle(fontSize: 24)),
          content: Text('$playerName は3回連続でゼロ得点を記録したため失格です。',
              style: TextStyle(fontSize: 24)),
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

  // スコアを編集するメソッド
  void _editScore(int playerIndex, int roundIndex) {
    int currentScore = scoreHistories[playerIndex].scores[roundIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('スコアを編集', style: TextStyle(fontSize: 24)),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: '新しいスコアを入力'),
            onChanged: (value) {
              currentScore = int.tryParse(value) ?? currentScore;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('キャンセル', style: TextStyle(fontSize: 24)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // スコアを更新
                  int difference = currentScore -
                      scoreHistories[playerIndex].scores[roundIndex];
                  players[playerIndex].score += difference;
                  scoreHistories[playerIndex].scores[roundIndex] = currentScore;
                });
                Navigator.of(context).pop();
              },
              child: Text('更新', style: TextStyle(fontSize: 24)),
            ),
          ],
        );
      },
    );
  }

  // スコアシートを表示するメソッド
  Widget _buildScoreSheet() {
    return Table(
      border: TableBorder.all(),
      children: [
        _buildHeaderRow(),
        ..._buildScoreRows(),
      ],
    );
  }

  // ヘッダー行（プレイヤー名）
  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        TableCell(
            child: Text('ラウンド',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center)),
        ...scoreHistories
            .map((history) => TableCell(
                child: Text(history.playerName,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center)))
            .toList(),
      ],
    );
  }

  // スコア履歴の各行
  List<TableRow> _buildScoreRows() {
    int maxRounds = scoreHistories
        .map((h) => h.scores.length)
        .reduce((a, b) => a > b ? a : b);

    return List<TableRow>.generate(maxRounds, (roundIndex) {
      return TableRow(
        children: [
          TableCell(
              child: Text('ラウンド ${roundIndex + 1}',
                  style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
          ...scoreHistories.asMap().entries.map((entry) {
            int playerIndex = entry.key;
            ScoreHistory history = entry.value;
            return TableCell(
              child: GestureDetector(
                onTap: roundIndex < history.scores.length
                    ? () => _editScore(playerIndex, roundIndex) // スコアをタップで編集
                    : null,
                child: Text(
                  roundIndex < history.scores.length
                      ? history.scores[roundIndex].toString()
                      : '',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mölkky Score Tracker', style: TextStyle(fontSize: 24)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
            SizedBox(height: 20),
            Text('スコアシート', style: TextStyle(fontSize: 24)),
            _buildScoreSheet(), // スコアシートを表示
          ],
        ),
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
