class Player {
  final String name;
  int score;
  int zeroScoreStreak;  // 連続でゼロ得点の回数を管理
  bool isDisqualified;  // 失格フラグ

  Player({required this.name, required this.score, required this.zeroScoreStreak, required this.isDisqualified});
}