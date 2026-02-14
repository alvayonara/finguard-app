import 'package:finguard_app/features/activity/data/model/category_info.dart';

sealed class ActivityItem {
  final DateTime timestamp;

  ActivityItem(this.timestamp);

  DateTime get displayDate => timestamp;

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final data = json['data'];

    return switch (type) {
      'TRANSACTION' => ActivityTransaction.fromJson(data),
      'RISK_CHANGE' => ActivityRiskChange.fromJson(data),
      _ => throw Exception('Unknown activity type: $type'),
    };
  }
}

class ActivityDateHeader extends ActivityItem {
  final String label;

  ActivityDateHeader(this.label, DateTime timestamp) : super(timestamp);
}

class ActivityTransaction extends ActivityItem {
  final int id;
  final String type;
  final double amount;
  final CategoryInfo category;
  final DateTime occurredAt;

  ActivityTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.occurredAt,
    required DateTime createdAt,
  }) : super(createdAt);

  @override
  DateTime get displayDate => occurredAt;

  factory ActivityTransaction.fromJson(Map<String, dynamic> json) {
    return ActivityTransaction(
      id: json['id'],
      type: json['type'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      category: CategoryInfo.fromJson(json['category']),
      occurredAt: DateTime.parse(json['occurredAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ActivityRiskChange extends ActivityItem {
  final String previousLevel;
  final String currentLevel;
  final String? topSignalType;

  ActivityRiskChange({
    required this.previousLevel,
    required this.currentLevel,
    this.topSignalType,
    required DateTime changedAt,
  }) : super(changedAt);

  factory ActivityRiskChange.fromJson(Map<String, dynamic> json) {
    return ActivityRiskChange(
      previousLevel: json['previousLevel'] ?? '',
      currentLevel: json['currentLevel'] ?? '',
      topSignalType: json['topSignalType'],
      changedAt: DateTime.parse(json['changedAt']),
    );
  }
}

