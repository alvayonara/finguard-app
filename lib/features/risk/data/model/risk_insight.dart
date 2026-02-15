class RiskInsight {
  final String type;
  final String severity;
  final String message;
  final String detectedAt;

  RiskInsight({
    required this.type,
    required this.severity,
    required this.message,
    required this.detectedAt,
  });

  factory RiskInsight.fromJson(Map<String, dynamic> json) {
    return RiskInsight(
      type: json['type'] ?? '',
      severity: json['severity'] ?? '',
      message: json['message'] ?? '',
      detectedAt: json['detectedAt'] ?? '',
    );
  }
}
