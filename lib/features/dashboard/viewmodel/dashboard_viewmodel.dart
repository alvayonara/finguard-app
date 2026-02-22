import 'package:finguard/features/dashboard/data/dashboard_repository.dart';
import 'package:finguard/features/dashboard/data/model/dashboard_response.dart';
import 'package:flutter/material.dart';

class DashboardViewmodel extends ChangeNotifier {
  final DashboardRepository dashboardRepository;

  DashboardViewmodel({required this.dashboardRepository});

  DashboardResponse? dashboardData;
  bool isLoading = false;
  bool isFinancialHealthUpdating = false;
  bool isMonthChanging = false;
  String? error;
  DateTime _selectedMonth = _monthStart(DateTime.now());
  int _monthSlideDirection = 1;

  DateTime get selectedMonth => _selectedMonth;
  int get monthSlideDirection => _monthSlideDirection;
  DateTime get maxSelectableMonth => _monthStart(DateTime.now());
  DateTime get minSelectableMonth =>
      _monthStart(DateTime(DateTime.now().year, DateTime.now().month - 1, 1));
  bool get canGoPreviousMonth =>
      !_isSameMonth(_selectedMonth, minSelectableMonth);

  bool get canGoNextMonth => !_isSameMonth(_selectedMonth, maxSelectableMonth);
  String get selectedMonthApiKey => _toMonthApiParam(_selectedMonth);

  Future<void> loadDashboard({bool showLoading = true}) async {
    try {
      error = null;
      if (showLoading) {
        isLoading = true;
        notifyListeners();
      }

      dashboardData = await dashboardRepository.fetchDashboard(
        month: _toMonthApiParam(_selectedMonth),
      );
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      if (showLoading) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> goToPreviousMonth() async {
    if (!canGoPreviousMonth) return;
    await _changeMonth(-1);
  }

  Future<void> goToNextMonth() async {
    if (!canGoNextMonth) return;
    await _changeMonth(1);
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

    if (previousLastDetectedAt != null && previousLastDetectedAt.isNotEmpty) {
      return latestLastDetectedAt != previousLastDetectedAt;
    }

    if (mutationTriggeredAt != null) {
      final latestParsed = DateTime.tryParse(latestLastDetectedAt);
      if (latestParsed == null) return false;

      final latestUtc = latestParsed.toUtc();
      final cutoffUtc = mutationTriggeredAt.toUtc().subtract(
        const Duration(seconds: 5),
      );
      return latestUtc.isAfter(cutoffUtc);
    }

    return false;
  }

  static DateTime _monthStart(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static String _toMonthApiParam(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }

  Future<void> _changeMonth(int deltaMonth) async {
    _monthSlideDirection = deltaMonth.isNegative ? -1 : 1;
    _selectedMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + deltaMonth,
      1,
    );
    isMonthChanging = true;
    notifyListeners();

    try {
      await loadDashboard(showLoading: false);
    } finally {
      isMonthChanging = false;
      notifyListeners();
    }
  }
}
