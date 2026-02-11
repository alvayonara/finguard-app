import 'package:finguard_app/features/dashboard/data/dashboard_repository.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';
import 'package:flutter/material.dart';

class DashboardViewmodel extends ChangeNotifier {
  final DashboardRepository dashboardRepository;

  DashboardViewmodel({required this.dashboardRepository});

  DashboardResponse? dashboardData;
  bool isLoading = false;
  String? error;

  Future<void> loadDashboard(String userUid) async {
    try {
      isLoading = true;
      notifyListeners();

      dashboardData = await dashboardRepository.fetchDashboard(userUid);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
