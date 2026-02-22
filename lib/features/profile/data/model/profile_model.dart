class ProfileModel {
  final String? name;
  final String? email;
  final String role;
  final String plan;
  final String preferredCurrency;
  final String preferredLanguage;
  final String createdAt;

  ProfileModel({
    this.name,
    this.email,
    required this.role,
    required this.plan,
    required this.preferredCurrency,
    required this.preferredLanguage,
    required this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      role: (json['role'] ?? 'USER').toString(),
      plan: (json['plan'] ?? 'FREE').toString(),
      preferredCurrency: (json['preferredCurrency'] ?? 'USD').toString(),
      preferredLanguage: (json['preferredLanguage'] ?? 'en').toString(),
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  bool get isPro => plan == "PRO";
}
