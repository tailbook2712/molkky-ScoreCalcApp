import 'package:flutter/material.dart';
import 'package:mollky_score_app/models/history_manager.dart';

class GameHistoryScreen extends StatefulWidget {
  @override
  _GameHistoryScreenState createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  List<Map<String, dynamic>> gameHistory = [];

  @override
  void initState() {
    super.initState();
    _loadGameHistory();
  }

  Future<void> _loadGameHistory() async {
    List history = await HistoryManager.getGameHistory();
    setState(() {
      gameHistory = history as List<Map<String, dynamic>>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ゲーム履歴', style: TextStyle(fontSize: 24)),
      ),
      body: ListView.builder(
        itemCount: gameHistory.length,
        itemBuilder: (context, index) {
          final game = gameHistory[index];
          return ListTile(
            title: Text('ゲーム日時: ${game['date']}', style: TextStyle(fontSize: 18)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (game['players'] as List).map((player) {
                return Text('${player['name']}: ${player['score']} 点', style: TextStyle(fontSize: 16));
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}