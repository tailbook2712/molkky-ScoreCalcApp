import 'package:flutter/material.dart';
import 'score_screen.dart';
import 'team_selection_screen.dart';

class GameModeSelectionScreen extends StatefulWidget {
  @override
  _GameModeSelectionScreenState createState() => _GameModeSelectionScreenState();
}

class _GameModeSelectionScreenState extends State<GameModeSelectionScreen> {
  bool _enableDisqualification = true;  // 失格モードのトグル状態

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ゲームモード選択', style: TextStyle(fontSize: 24)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 失格モードのトグルスイッチ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _enableDisqualification ? '失格モード有効' : '失格モード無効',
                    style: TextStyle(fontSize: 20),
                  ),
                  Switch(
                    value: _enableDisqualification,
                    onChanged: (value) {
                      setState(() {
                        _enableDisqualification = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 一人モード：スコア画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreScreen(
                        teamNames: ['Player 1'],  // 一人用のデフォルトチーム名
                        enableDisqualification: _enableDisqualification,  // 失格モードの状態を渡す
                      ),
                    ),
                  );
                },
                child: Text('一人で遊ぶ', style: TextStyle(fontSize: 24)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 複数人モード：チーム選択画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamSelectionScreen(
                        enableDisqualification: _enableDisqualification,  // トグルの状態を渡す
                      ),
                    ),
                  );
                },
                child: Text('複数人で遊ぶ', style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}