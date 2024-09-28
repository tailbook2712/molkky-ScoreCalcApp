import 'package:flutter/material.dart';
import 'team_name_screen.dart';
import 'score_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool enableDisqualification;  // 失格機能の状態を受け取る

  TeamSelectionScreen({required this.enableDisqualification});

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

  void _navigateToNextScreen(BuildContext context) {
    int? teamCount = int.tryParse(_teamCountController.text);
    if (teamCount != null && teamCount > 1) {
      // 複数人モードの場合、チーム名入力画面へ遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamNameScreen(
            teamCount: teamCount,
            enableDisqualification: widget.enableDisqualification,  // ゲームモード画面からの状態を渡す
          ),
        ),
      );
    } else if (teamCount == 1) {
      // 一人モードの場合、直接スコア画面へ遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScoreScreen(
            teamNames: ['Player 1'],  // 一人用のデフォルトチーム名
            enableDisqualification: widget.enableDisqualification,  // ゲームモード画面からの状態を渡す
          ),
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
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToNextScreen(context),
                child: Text('次へ', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}