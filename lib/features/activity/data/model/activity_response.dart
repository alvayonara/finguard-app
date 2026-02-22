import 'package:finguard/features/activity/data/model/activity_item.dart';
import 'package:finguard/features/activity/data/model/insight_card.dart';

class ActivityResponse {
  final InsightCard? insight;
  final List<ActivityItem> items;
  final String? nextCursorTime;
  final int? nextCursorId;

  ActivityResponse({
    this.insight,
    required this.items,
    this.nextCursorTime,
    this.nextCursorId,
  });

  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    return ActivityResponse(
      insight: json['insight'] != null
          ? InsightCard.fromJson(json['insight'])
          : null,
      items: (json['items'] as List? ?? [])
          .map((item) => ActivityItem.fromJson(item))
          .toList(),
      nextCursorTime: json['nextCursorTime'],
      nextCursorId: json['nextCursorId'],
    );
  }

  bool get hasMore => nextCursorTime != null;
}
