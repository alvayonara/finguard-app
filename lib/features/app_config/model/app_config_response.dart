class AppConfigResponse {
  final bool subscriptionEnabled;
  final bool communityEnabled;

  AppConfigResponse({
    required this.subscriptionEnabled,
    required this.communityEnabled,
  });

  factory AppConfigResponse.fromJson(Map<String, dynamic> json) {
    return AppConfigResponse(
      subscriptionEnabled: json['subscriptionEnabled'] ?? false,
      communityEnabled: json['communityEnabled'] ?? false,
    );
  }
}
