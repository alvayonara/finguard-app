class GoogleLoginRequest {
  final String idToken;
  final String? anonymousId;

  GoogleLoginRequest({required this.idToken, this.anonymousId});

  Map<String, dynamic> toJson() => {
        'idToken': idToken,
        if (anonymousId != null) 'anonymousId': anonymousId,
      };
}
