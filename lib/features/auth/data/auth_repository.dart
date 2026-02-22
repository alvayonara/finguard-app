import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/auth/data/model/auth_response.dart';
import 'package:uuid/uuid.dart';

import 'google_login_request.dart';

class AuthRepository {
  final ApiClient apiClient;
  final _uuid = const Uuid();

  AuthRepository(this.apiClient);
  Future<AuthResponse> loginWithGoogle({required String idToken}) async {
    final response = await apiClient.dio.post(
      "/v1/users/google",
      data: GoogleLoginRequest(idToken: idToken).toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }
}
