class ProfileModel {
  final String userUid;
  final String? name;
  final String? email;
  final String role;
  final String plan;
  final String preferredCurrency;
  final String preferredLanguage;
  final String createdAt;

  ProfileModel({
    required this.userUid,
    this.name,
    this.email,
    required this.role,
    required this.plan,
    required this.preferredCurrency,
    required this.preferredLanguage,
    required this.createdAt,
  });
  bool get isPro => plan == "PRO";
}
