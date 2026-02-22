import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/user/data/model/user_preference.dart';
import 'package:finguard/features/user/data/model/user_preference_response.dart';

class UserRepository {
  final ApiClient apiClient;
  UserRepository({required this.apiClient});

  Future<UserPreference> getPreferences() async {
    final res = await apiClient.dio.get("/v1/user/preferences");
    final response = UserPreferenceResponse.fromJson(res.data);
    return UserPreference(
      language: response.language ?? 'en',
      currency: response.currency ?? 'USD',
    );
  }

  Future<void> updatePreferences(String currency, String language) async {
    await apiClient.dio.put(
      '/v1/user/preferences',
      data: {'currency': currency, 'language': language},
    );
  }

  Future<void> completeOnboarding() async {
    await apiClient.dio.post('/v1/users/onboarding/complete');
  }
}
