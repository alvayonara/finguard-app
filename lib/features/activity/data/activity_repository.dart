import 'package:dio/dio.dart';
import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/activity/data/model/activity_response.dart';

class ActivityRepository {
  final ApiClient apiClient;

  ActivityRepository(this.apiClient);

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

    try {
      final response = await apiClient.dio.get(
        '/v1/activity',
        queryParameters: queryParams,
      );

      return ActivityResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Activity endpoint not available');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server is taking too long to respond.');
      }
      throw Exception('Failed to load activities: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load activities: $e');
    }
  }
}
