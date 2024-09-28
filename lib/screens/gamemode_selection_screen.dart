import 'package:flutter/material.dart';
import 'score_screen.dart';  // スコア画面を直接呼び出す
import 'team_selection_screen.dart';  // 複数人モードのための画面を呼び出す

class GameModeSelectionScreen extends StatelessWidget {
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
              ElevatedButton(
                onPressed: () {
                  // 一人モード：チーム名入力を省略してスコア画面へ遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreScreen(
                        teamNames: ['Player 1'],  // 一人用のデフォルトチーム名
                        enableDisqualification: true,  // 失格モードの初期状態
                      ),
                    ),
                  );
                },
                child: Text('一人で遊ぶ', style: TextStyle(fontSize: 24)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 複数人モード：チーム選択画面に遷移
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamSelectionScreen(),
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