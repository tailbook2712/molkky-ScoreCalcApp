import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryManager {
  static const String _historyKey = 'game_history';
  static const int maxHistory = 10;

  // ゲーム履歴を保存する
  static Future<void> saveGameHistory(Map<String, dynamic> gameData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_historyKey) ?? [];

    // ゲーム履歴を10件に制限
    if (historyList.length >= maxHistory) {
      historyList.removeAt(0);  // 古い履歴を削除
    }

    historyList.add(jsonEncode(gameData));
    await prefs.setStringList(_historyKey, historyList);
  }

  // ゲーム履歴を取得する
  static Future<List<Map<String, dynamic>>> getGameHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historyList = prefs.getStringList(_historyKey) ?? [];

    // List<dynamic> を明示的に List<Map<String, dynamic>> に変換
    List<Map<String, dynamic>> result = historyList.map((item) {
      return Map<String, dynamic>.from(jsonDecode(item) as Map);
    }).toList();

    return result;
  }
}