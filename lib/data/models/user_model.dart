class UserModel {
  final String userId;
  final String anonymousId;

  UserModel({required this.userId, required this.anonymousId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      anonymousId: json['anonymousId'],
    );
  }
}
