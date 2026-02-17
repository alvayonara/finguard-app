import 'package:finguard_app/core/network/api_client.dart';
import 'package:finguard_app/features/auth/data/model/auth_response.dart';
import 'package:uuid/uuid.dart';

import 'google_login_request.dart';

class AuthRepository {
  final ApiClient apiClient;
  final _uuid = const Uuid();

  AuthRepository(this.apiClient);

  Future<AuthResponse> createAnonymous({String? anonymousId}) async {
    final resolvedAnonymousId = anonymousId ?? _uuid.v4();
    final response = await apiClient.dio.post(
      "/v1/users/anonymous",
      data: {"anonymousId": resolvedAnonymousId},
    );
    return AuthResponse.fromJson(
      response.data,
    ).copyWith(anonymousId: resolvedAnonymousId);
  }

  Future<AuthResponse> loginWithGoogle({required String idToken, String? anonymousId}) async {
    final response = await apiClient.dio.post(
      "/v1/users/google",
      data: GoogleLoginRequest(idToken: idToken, anonymousId: anonymousId).toJson(),
    );
    return AuthResponse.fromJson(response.data);
  }
}
