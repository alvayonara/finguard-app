import 'package:uuid/uuid.dart';
import '../../core/storage/local_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;
  final LocalStorage localStorage;
  final _uuid = const Uuid();

  AuthRepository({
    required this.authRemoteDatasource,
    required this.localStorage,
  });

  Future<UserModel?> getSavedUser() async {
    final id = await localStorage.getUserId();
    final anonymousId = await localStorage.getAnonymousId();
    if (id == null || anonymousId == null) {
      return null;
    }
    return UserModel(userId: id, anonymousId: anonymousId);
  }

  Future<UserModel> createAnonymousUser() async {
    final existing = await getSavedUser();
    if (existing != null) {
      return existing;
    }
    final anonymousId = _uuid.v4();
    final user = await authRemoteDatasource.createAnonymous(anonymousId);
    await localStorage.saveUser(user.anonymousId, user.userId);
    return user;
  }
}
