import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/app_config/model/app_config_response.dart';

class AppConfigRepository {
  final ApiClient apiClient;

  AppConfigRepository({required this.apiClient});

  Future<AppConfigResponse> getConfig({
    required String platform,
    required String version,
  }) async {
    final response = await apiClient.dio.get(
      '/v1/app-config',
      queryParameters: {'platform': platform, 'version': version},
    );
    return AppConfigResponse.fromJson(response.data);
  }
}
