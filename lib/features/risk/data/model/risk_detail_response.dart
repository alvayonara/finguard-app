class RiskDetailResponse {
  final String currentLevel;
  final int score;
  final String color;
  final String topInsightKey;
  final String recommendationKey;
  final String? lastDetectedAt;
  final List<RiskSignalSummary> activeSignalSummaries;
  final List<RiskLevelChange> recentLevelChanges;

  RiskDetailResponse({
    required this.currentLevel,
    required this.score,
    required this.color,
    required this.topInsightKey,
    required this.recommendationKey,
    required this.lastDetectedAt,
    required this.activeSignalSummaries,
    required this.recentLevelChanges,
  });

  factory RiskDetailResponse.fromJson(Map<String, dynamic> json) {
    return RiskDetailResponse(
      currentLevel: json['currentLevel'] ?? '',
      score: json['score'] ?? 0,
      color: json['color'] ?? '',
      topInsightKey: json['topInsightKey'] ?? '',
      recommendationKey: json['recommendationKey'] ?? '',
      lastDetectedAt: json['lastDetectedAt'],
      activeSignalSummaries:
          (json['activeSignalSummaries'] as List?)
              ?.map((e) => RiskSignalSummary.fromJson(e))
              .toList() ??
          [],
      recentLevelChanges:
          (json['recentLevelChanges'] as List?)
              ?.map((e) => RiskLevelChange.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class RiskSignalSummary {
  final String signalType;
  final String severity;
  final int occurrences;
  final String lastDetectedAt;

  RiskSignalSummary({
    required this.signalType,
    required this.severity,
    required this.occurrences,
    required this.lastDetectedAt,
  });

  factory RiskSignalSummary.fromJson(Map<String, dynamic> json) {
    return RiskSignalSummary(
      signalType: json['signalType'] ?? '',
      severity: json['severity'] ?? '',
      occurrences: json['occurrences'] ?? 0,
      lastDetectedAt: json['lastDetectedAt'] ?? '',
    );
  }
}

class RiskLevelChange {
  final String oldLevel;
  final String newLevel;
  final String occurredAt;

  RiskLevelChange({
    required this.oldLevel,
    required this.newLevel,
    required this.occurredAt,
  });

  factory RiskLevelChange.fromJson(Map<String, dynamic> json) {
    return RiskLevelChange(
      oldLevel: json['oldLevel'] ?? '',
      newLevel: json['newLevel'] ?? '',
      occurredAt: json['occurredAt'] ?? '',
    );
  }
}
