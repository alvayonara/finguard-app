import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/dashboard/data/model/dashboard_response.dart';

class DashboardRepository {
  final ApiClient apiClient;
  DashboardRepository({required this.apiClient});

  Future<DashboardResponse> fetchDashboard({String? month}) async {
    final response = await apiClient.dio.get(
      '/v1/dashboard',
      queryParameters: month != null ? {'month': month} : null,
    );
    return DashboardResponse.fromJson(response.data);
  }
}
