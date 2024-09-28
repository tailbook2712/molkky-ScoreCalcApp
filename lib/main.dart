import 'package:flutter/material.dart';
import 'package:mollky_score_app/screens/gamemode_selection_screen.dart';

void main() => runApp(MolkkyApp());

class MolkkyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mölkky Score App',
      home: (GameModeSelectionScreen()),  // チーム人数選択画面を最初に表示
    );
  }
}