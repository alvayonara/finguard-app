class UserPreference {
  final String language;
  final String currency;

  const UserPreference({
    required this.language,
    required this.currency,
  });

  UserPreference copyWith({
    String? language,
    String? currency,
  }) {
    return UserPreference(
      language: language ?? this.language,
      currency: currency ?? this.currency,
    );
  }
}