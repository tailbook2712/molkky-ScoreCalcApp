import 'package:flutter/material.dart';

class AppTheme {
  // 背景色
  static const Color background = Color(0xFFFEF9F2);

  // ボタン色
  static const Color primaryButton = Color(0xFFA4CF64);
  static const Color secondaryButton = Color(0xFFDCC6B0);

  // テキスト色
  static const Color textDark = Colors.black87;
  static const Color textLight = Colors.white;

  // アクティブ色（ラジオボタンなど）
  static const Color accent = Colors.brown;

  // ボタンスタイル
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryButton,
    shape: StadiumBorder(),
    textStyle: TextStyle(fontSize: 18),
  );

  // テキストスタイル
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textDark,
  );

  static const TextStyle label = TextStyle(
    fontSize: 18,
    color: textDark,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 20,
    color: textLight,
  );
}
