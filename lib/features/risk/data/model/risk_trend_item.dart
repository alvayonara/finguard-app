class RiskTrendItem {
  final String date;
  final String level;
  final int score;

  RiskTrendItem({required this.date, required this.level, required this.score});

  factory RiskTrendItem.fromJson(Map<String, dynamic> json) {
    return RiskTrendItem(
      date: json["date"],
      level: json["level"],
      score: json["score"],
    );
  }
}
