import 'package:flutter/material.dart';
import 'team_name_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  @override
  _TeamSelectionScreenState createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final TextEditingController _teamCountController = TextEditingController();
  String _errorMessage = '';
  bool _enableDisqualification = true;  // 失格機能のトグル状態

  @override
  void dispose() {
    _teamCountController.dispose();
    super.dispose();
  }

  void _navigateToTeamNameScreen(BuildContext context) {
    int? teamCount = int.tryParse(_teamCountController.text);
    if (teamCount != null && teamCount > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamNameScreen(
            teamCount: teamCount,
            enableDisqualification: _enableDisqualification,  // トグルボタンの状態を渡す
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _enableDisqualification ? '失格モード有効' : '失格モード無効',  // トグルに応じたテキスト
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