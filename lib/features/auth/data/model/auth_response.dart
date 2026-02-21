class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userUid;
  final List<String> roles;
  final String? plan;
  final bool onboardingCompleted;
  final bool initialIncomeSet;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userUid,
    required this.roles,
    this.plan,
    this.onboardingCompleted = false,
    this.initialIncomeSet = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userUid: json['userUid'],
      roles: (json['roles'] as List<dynamic>? ?? []).cast<String>(),
      plan: json['plan'] as String?,
      onboardingCompleted: json['onboardingCompleted'] == true,
      initialIncomeSet: json['initialIncomeSet'] == true,
    );
  }

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? userUid,
    List<String>? roles,
    String? plan,
    bool? onboardingCompleted,
    bool? initialIncomeSet,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userUid: userUid ?? this.userUid,
      roles: roles ?? this.roles,
      plan: plan ?? this.plan,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      initialIncomeSet: initialIncomeSet ?? this.initialIncomeSet,
    );
  }
}
