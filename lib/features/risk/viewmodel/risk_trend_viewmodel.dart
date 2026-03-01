import 'package:finguard/features/risk/data/model/risk_trend_item.dart';
import 'package:finguard/features/risk/data/risk_repository.dart';
import 'package:flutter/foundation.dart';

class RiskTrendViewmodel extends ChangeNotifier {
  final RiskRepository riskRepository;

  RiskTrendViewmodel({required this.riskRepository});
  bool isLoading = false;
  List<RiskTrendItem> data = [];
  int selectedDays = 7;

  Future<void> load({int? days}) async {
    if (days != null) {
      selectedDays = days;
    }
    isLoading = true;
    notifyListeners();

    try {
      data = await riskRepository.getTrend(selectedDays);
    } catch (_) {
      data = [];
    }

    isLoading = false;
    notifyListeners();
  }

  String get trendDirection {
    if (data.length < 2) return "STABLE";

    final first = data.first.score;
    final last = data.last.score;

    if (last > first) return "UP";
    if (last < first) return "DOWN";
    return "STABLE";
  }
}
