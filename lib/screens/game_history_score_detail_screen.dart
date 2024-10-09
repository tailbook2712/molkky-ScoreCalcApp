import 'package:flutter/material.dart';

class GameHistoryScoreDetailScreen extends StatelessWidget {
  final Map<String, dynamic> game;

  GameHistoryScoreDetailScreen({required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('スコアシート (${game['date']})', style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ゲーム日時: ${game['date']}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('ラウンドごとのスコア:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    _buildHeaderRow(),
                    ..._buildScoreRows(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ヘッダー行（プレイヤー名）
  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        TableCell(child: Text('ラウンド', style: TextStyle(fontSize: 18), textAlign: TextAlign.center)),
        ...game['players'].map<TableCell>((player) {
          return TableCell(
            child: Text(player['name'], style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          );
        }).toList(),
      ],
    );
  }

  // スコア履歴の各行
  List<TableRow> _buildScoreRows() {
    int maxRounds = game['players'][0]['scores'] != null ? (game['players'][0]['scores'] as List).length : 0;

    return List<TableRow>.generate(maxRounds, (roundIndex) {
      return TableRow(
        children: [
          TableCell(child: Text('ラウンド ${roundIndex + 1}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center)),
          ...game['players'].map<TableCell>((player) {
            List<int> scores = List<int>.from(player['scores'] ?? []);
            return TableCell(
              child: Text(scores.length > roundIndex ? scores[roundIndex].toString() : '-', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            );
          }).toList(),
        ],
      );
    });
  }
}