class UploadTicketModel {
  const UploadTicketModel({
    required this.photoId,
    required this.uploadUrl,
    required this.expiresAt,
  });

  final String photoId;
  final String uploadUrl;
  final DateTime expiresAt;

  factory UploadTicketModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return UploadTicketModel(
      photoId: data['photo_id'] as String,
      uploadUrl: data['upload_url'] as String,
      expiresAt: DateTime.parse(data['expires_at'] as String),
    );
  }
}
