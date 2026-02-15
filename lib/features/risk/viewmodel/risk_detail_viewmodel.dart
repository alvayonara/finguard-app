import 'package:finguard_app/features/risk/data/model/risk_detail_response.dart';
import 'package:finguard_app/features/risk/data/model/risk_insight.dart';
import 'package:finguard_app/features/risk/data/model/risk_trend_item.dart';
import 'package:finguard_app/features/risk/data/risk_repository.dart';
import 'package:flutter/foundation.dart';

class RiskDetailViewmodel extends ChangeNotifier {
  final RiskRepository repository;

  bool isLoading = false;
  String? error;
  RiskDetailResponse? data;
  List<RiskTrendItem> trendData = [];
  List<RiskInsight> insights = [];

  RiskDetailViewmodel({required this.repository});

  Future<void> load() async {
    try {
      isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        repository.getDetail(),
        repository.getTrend(7),
        repository.getInsights(),
      ]);

      data = results[0] as RiskDetailResponse;
      trendData = results[1] as List<RiskTrendItem>;
      insights = results[2] as List<RiskInsight>;
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getTrendDirection() {
    if (trendData.length < 2) return "STABLE";
    final first = trendData.first.score;
    final last = trendData.last.score;
    final diff = last - first;
    if (diff > 5) return "UP";
    if (diff < -5) return "DOWN";
    return "STABLE";
  }
}
