import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/auth/data/model/auth_response.dart';

import 'google_login_request.dart';
import 'model/refresh_token_request.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    final response = await apiClient.dio.post(
      "/v1/users/google",
      data: GoogleLoginRequest(idToken: idToken).toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<void> logout({required String refreshToken}) async {
    await apiClient.dio.post(
      "/v1/users/logout",
      data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
    );
  }
}
