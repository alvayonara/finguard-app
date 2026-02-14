class InsightCard {
  final String title;
  final String message;
  final String insightType;

  InsightCard({
    required this.title,
    required this.message,
    required this.insightType,
  });

  factory InsightCard.fromJson(Map<String, dynamic> json) {
    return InsightCard(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      insightType: json['insightType'] ?? 'LOW',
    );
  }
}
