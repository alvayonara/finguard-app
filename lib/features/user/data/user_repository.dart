import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/profile/data/model/profile_model.dart';
import 'package:finguard/features/user/data/model/user_preference.dart';
import 'package:finguard/features/user/data/model/user_preference_response.dart';

class UserRepository {
  final ApiClient apiClient;
  UserRepository({required this.apiClient});

  Future<UserPreference> getPreferences() async {
    try {
      final res = await apiClient.dio.get("/v1/users/preferences");
      final response = UserPreferenceResponse.fromJson(res.data);
      return UserPreference(
        language: response.language ?? 'en',
        currency: response.currency ?? 'USD',
      );
    } catch (_) {
      final res = await apiClient.dio.get("/v1/user/preferences");
      final response = UserPreferenceResponse.fromJson(res.data);
      return UserPreference(
        language: response.language ?? 'en',
        currency: response.currency ?? 'USD',
      );
    }
  }

  Future<void> updatePreferences(String currency, String language) async {
    try {
      await apiClient.dio.put(
        '/v1/users/preferences',
        data: {'currency': currency, 'language': language},
      );
    } catch (_) {
      await apiClient.dio.put(
        '/v1/user/preferences',
        data: {'currency': currency, 'language': language},
      );
    }
  }

  Future<void> completeOnboarding() async {
    await apiClient.dio.post('/v1/users/onboarding/complete');
  }

  Future<ProfileModel> getMe() async {
    final res = await apiClient.dio.get('/v1/users/me');
    return ProfileModel.fromJson(res.data as Map<String, dynamic>);
  }
}
