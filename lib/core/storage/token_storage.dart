import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'access_token';
  static const _expiresAtKey = 'expires_at';

  final FlutterSecureStorage _storage;

  Future<void> saveSession({
    required String accessToken,
    required String expiresAtIso,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _expiresAtKey, value: expiresAtIso);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readExpiresAt() => _storage.read(key: _expiresAtKey);

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
