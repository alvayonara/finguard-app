class UserModel {
  final String userUid;
  final String anonymousId;

  UserModel({required this.userUid, required this.anonymousId});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userUid: json['userUid'],
      anonymousId: json['anonymousId'],
    );
  }
}
