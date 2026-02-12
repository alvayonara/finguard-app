class UserPreferenceResponse {
  final String? language;
  final String? currency;

  UserPreferenceResponse({
    this.language,
    this.currency,
  });

  factory UserPreferenceResponse.fromJson(Map<String, dynamic> json) {
    return UserPreferenceResponse(
      language: json['language'],
      currency: json['currency'],
    );
  }
}