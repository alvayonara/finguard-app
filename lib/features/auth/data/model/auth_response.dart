class AuthResponse {
  final String userUid;
  final String anonymousId;

  AuthResponse({required this.userUid, required this.anonymousId});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userUid: json['userUid'],
      anonymousId: json['anonymousId'],
    );
  }
}
