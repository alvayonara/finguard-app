import 'package:finguard_app/features/risk/data/model/risk_detail_response.dart';
import 'package:finguard_app/features/risk/data/risk_repository.dart';
import 'package:flutter/foundation.dart';

class RiskDetailViewmodel extends ChangeNotifier {
  final RiskRepository repository;

  bool isLoading = false;
  String? error;
  RiskDetailResponse? data;

  RiskDetailViewmodel({required this.repository});

  Future<void> load() async {
    try {
      isLoading = true;
      notifyListeners();

      data = await repository.getDetail();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}