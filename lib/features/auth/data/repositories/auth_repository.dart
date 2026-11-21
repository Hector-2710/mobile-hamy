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
    return _saveSession(session);
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
    return _saveSession(session);
  }

  /// Intercambia un ID token de Google por una sesión normal de hamy.
  Future<SessionModel> loginWithGoogle({required String idToken}) async {
    final session = await remote.loginWithGoogle(idToken: idToken);
    return _saveSession(session);
  }

  Future<UserModel> me() => remote.me();

  Future<bool> hasToken() async {
    final token = await tokenStorage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => tokenStorage.clear();

  Future<SessionModel> _saveSession(SessionModel session) async {
    await tokenStorage.saveSession(
      accessToken: session.accessToken,
      expiresAtIso: session.expiresAt.toIso8601String(),
    );
    return session;
  }
}
