import 'user_model.dart';

class SessionModel {
  const SessionModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;
  final UserModel user;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return SessionModel(
      accessToken: data['access_token'] as String,
      tokenType: data['token_type'] as String? ?? 'Bearer',
      expiresAt: DateTime.parse(data['expires_at'] as String),
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
