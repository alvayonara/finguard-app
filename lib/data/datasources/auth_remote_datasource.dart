import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient apiClient;

  AuthRemoteDatasource({required this.apiClient});

  Future<UserModel> createAnonymous(String anonymousId) async {
    final response = await apiClient.post('/v1/users/anonymous', {
      'anonymousId': anonymousId,
    });
    return UserModel.fromJson(response);
  }
}