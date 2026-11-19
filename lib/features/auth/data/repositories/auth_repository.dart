import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({required this.remote, required this.tokenStorage});

  final AuthRemoteDatasource remote;
  final TokenStorage tokenStorage;

  Future<SessionModel> login({
    required String email,
    required String password,
  }) async {
    final session = await remote.login(email: email, password: password);
    await tokenStorage.saveSession(
      accessToken: session.accessToken,
      expiresAtIso: session.expiresAt.toIso8601String(),
    );
    return session;
  }

  Future<SessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await remote.register(
      name: name,
      email: email,
      password: password,
    );
    await tokenStorage.saveSession(
      accessToken: session.accessToken,
      expiresAtIso: session.expiresAt.toIso8601String(),
    );
    return session;
  }

  Future<UserModel> me() => remote.me();

  Future<bool> hasToken() async {
    final token = await tokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => tokenStorage.clear();
}
