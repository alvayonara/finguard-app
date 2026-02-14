class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userUid;
  final List<String> roles;
  final String? anonymousId;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userUid,
    required this.roles,
    this.anonymousId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userUid: json['userUid'],
      roles: (json['roles'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? userUid,
    List<String>? roles,
    String? anonymousId,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userUid: userUid ?? this.userUid,
      roles: roles ?? this.roles,
      anonymousId: anonymousId ?? this.anonymousId,
    );
  }
}
