import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/session_model.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  AuthRemoteDatasource(this._client);

  final ApiClient _client;

  Future<SessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return SessionModel.fromJson(response.data!);
  }

  Future<SessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return SessionModel.fromJson(response.data!);
  }

  Future<UserModel> me() async {
    final response = await _client.get<Map<String, dynamic>>(ApiEndpoints.me);
    final data = response.data!['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
