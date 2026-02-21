import 'package:finguard_app/features/activity/data/activity_repository.dart';
import 'package:finguard_app/features/activity/data/model/activity_item.dart';
import 'package:finguard_app/features/activity/data/model/insight_card.dart';
import 'package:flutter/material.dart';

class ActivityViewmodel extends ChangeNotifier {
  final ActivityRepository activityRepository;

  ActivityViewmodel({required this.activityRepository});

  InsightCard? insight;
  List<ActivityItem> items = [];
  String? nextCursorTime;
  int? nextCursorId;

  bool isLoading = false;
  bool isLoadingMore = false;
  String? error;

  bool get hasMore => nextCursorTime != null;

  Future<void> loadActivities({bool refresh = false}) async {
    if (refresh) {
      isLoading = true;
      error = null;
      notifyListeners();
    }

    try {
      final response = await activityRepository.getActivities();

      insight = response.insight;
      items = _groupByDate(response.items);
      nextCursorTime = response.nextCursorTime;
      nextCursorId = response.nextCursorId;
      error = null;
    } catch (e) {
      error = e.toString();
      if (refresh) {
        insight = null;
        items = [];
        nextCursorTime = null;
        nextCursorId = null;
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final response = await activityRepository.getActivities(
        cursorTime: nextCursorTime!,
        cursorId: nextCursorId!,
      );

      final newItems = _groupByDate(response.items);
      items.addAll(newItems);
      nextCursorTime = response.nextCursorTime;
      nextCursorId = response.nextCursorId;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  List<ActivityItem> _groupByDate(List<ActivityItem> activityItems) {
    final List<ActivityItem> result = [];
    final Map<String, List<ActivityItem>> grouped = {};

    for (final item in activityItems) {
      final group = _getDateGroup(item.displayDate);
      grouped.putIfAbsent(group, () => []);
      grouped[group]!.add(item);
    }

    for (final entry in grouped.entries) {
      final label = entry.key;
      final items = entry.value;

      result.add(ActivityDateHeader(label, items.first.displayDate));
      result.addAll(items);
    }

    return result;
  }

  String _getDateGroup(DateTime displayDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(
      displayDate.year,
      displayDate.month,
      displayDate.day,
    );

    final difference = today.difference(itemDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference <= 7) return "This Week";
    return "Older";
  }
}
