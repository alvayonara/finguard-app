import 'package:dio/dio.dart';
import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/app_config/model/app_config_response.dart';

class AppConfigRepository {
  final ApiClient apiClient;

  AppConfigRepository(this.apiClient);

  Future<AppConfigResponse> getConfig({
    required String platform,
    required String version,
  }) async {
    final response = await apiClient.dio.get(
      '/v1/app-config',
      options: Options(
        headers: <String, String>{
          'X-Platform': platform,
          'X-App-Version': version,
        },
      ),
    );
    return AppConfigResponse.fromJson(response.data);
  }
}
