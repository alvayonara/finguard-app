import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/activity/data/model/activity_response.dart';

class ActivityRepository {
  final ApiClient apiClient;

  ActivityRepository({required this.apiClient});

  Future<ActivityResponse> getActivities({
    String? cursorTime,
    int? cursorId,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{'limit': limit};

    if (cursorTime != null) {
      queryParams['cursorTime'] = cursorTime;
    }

    if (cursorId != null) {
      queryParams['cursorId'] = cursorId;
    }

    final response = await apiClient.dio.get(
      '/v1/activity',
      queryParameters: queryParams,
    );

    return ActivityResponse.fromJson(response.data);
  }
}
