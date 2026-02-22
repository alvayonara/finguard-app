import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/app_version/data/model/app_version_response.dart';

class AppVersionRepository {
  final ApiClient apiClient;

  AppVersionRepository({required this.apiClient});

  Future<AppVersionResponse> checkVersion({
    required String platform,
    required String version,
  }) async {
    final response = await apiClient.dio.get(
      '/v1/app/version',
      queryParameters: {'platform': platform, 'version': version},
    );

    return AppVersionResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
