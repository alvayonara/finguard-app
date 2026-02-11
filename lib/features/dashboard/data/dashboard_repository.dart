import 'package:dio/dio.dart';
import 'package:finguard_app/core/network/api_client.dart';
import 'package:finguard_app/features/dashboard/data/model/dashboard_response.dart';

class DashboardRepository {
  final ApiClient apiClient;
  DashboardRepository({required this.apiClient});

  Future<DashboardResponse> fetchDashboard(String userUid) async {
    final response = await apiClient.dio.get(
      '/v1/dashboard',
      options: Options(headers: {'X-User-Uid': userUid}),
    );
    return DashboardResponse.fromJson(response.data);
  }
}
