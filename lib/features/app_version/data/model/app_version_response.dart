class AppVersionResponse {
  final String minSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final String? storeUrl;
  final bool mustUpdate;

  AppVersionResponse({
    required this.minSupportedVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.maintenanceMode,
    this.maintenanceMessage,
    this.storeUrl,
    required this.mustUpdate,
  });

  factory AppVersionResponse.fromJson(Map<String, dynamic> json) {
    return AppVersionResponse(
      minSupportedVersion: (json['minSupportedVersion'] ?? '').toString(),
      latestVersion: (json['latestVersion'] ?? '').toString(),
      forceUpdate: json['forceUpdate'] == true,
      maintenanceMode: json['maintenanceMode'] == true,
      maintenanceMessage: json['maintenanceMessage']?.toString(),
      storeUrl: json['storeUrl']?.toString(),
      mustUpdate: json['mustUpdate'] == true,
    );
  }
}
