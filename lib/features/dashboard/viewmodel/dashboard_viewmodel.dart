import 'package:finguard_app/features/dashboard/data/dashboard_repository.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';
import 'package:flutter/material.dart';

class DashboardViewmodel extends ChangeNotifier {
  final DashboardRepository dashboardRepository;

  DashboardViewmodel({required this.dashboardRepository});

  DashboardResponse? dashboardData;
  bool isLoading = false;
  bool isFinancialHealthUpdating = false;
  String? error;

  Future<void> loadDashboard({bool showLoading = true}) async {
    try {
      if (showLoading) {
        isLoading = true;
        error = null;
        notifyListeners();
      }

      dashboardData = await dashboardRepository.fetchDashboard();
    } catch (e) {
      error = e.toString();
    } finally {
      if (showLoading) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> refreshFinancialHealthWithPolling({
    String? previousLastDetectedAt,
    DateTime? mutationTriggeredAt,
    int maxAttempts = 8,
    Duration interval = const Duration(seconds: 1),
  }) async {
    isFinancialHealthUpdating = true;
    notifyListeners();

    try {
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        await loadDashboard(showLoading: false);
        final latestLastDetectedAt =
            dashboardData?.financialHealth?.lastDetectedAt;

        final hasNewDetectionTimestamp = _hasFreshFinancialHealthTimestamp(
          previousLastDetectedAt: previousLastDetectedAt,
          latestLastDetectedAt: latestLastDetectedAt,
          mutationTriggeredAt: mutationTriggeredAt,
        );

        if (hasNewDetectionTimestamp) {
          break;
        }

        if (attempt < maxAttempts - 1) {
          await Future.delayed(interval);
        }
      }
    } finally {
      isFinancialHealthUpdating = false;
      notifyListeners();
    }
  }

  bool _hasFreshFinancialHealthTimestamp({
    required String? previousLastDetectedAt,
    required String? latestLastDetectedAt,
    required DateTime? mutationTriggeredAt,
  }) {
    if (latestLastDetectedAt == null || latestLastDetectedAt.isEmpty) {
      return false;
    }

    // Ideal path: compare to known previous value.
    if (previousLastDetectedAt != null && previousLastDetectedAt.isNotEmpty) {
      return latestLastDetectedAt != previousLastDetectedAt;
    }

    // Fallback path when previous value is unavailable:
    // consider "fresh" only if latest timestamp is near/after mutation time.
    if (mutationTriggeredAt != null) {
      final latestParsed = DateTime.tryParse(latestLastDetectedAt);
      if (latestParsed == null) return false;

      final latestUtc = latestParsed.toUtc();
      final cutoffUtc =
          mutationTriggeredAt.toUtc().subtract(const Duration(seconds: 5));
      return latestUtc.isAfter(cutoffUtc);
    }

    return false;
  }
}
