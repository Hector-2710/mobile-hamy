class PhotoModel {
  const PhotoModel({
    required this.id,
    required this.albumId,
    required this.originalFilename,
    required this.contentType,
    required this.sizeBytes,
    required this.status,
    required this.createdAt,
    this.uploadedBy,
    this.width,
    this.height,
  });

  final String id;
  final String albumId;
  final String? uploadedBy;
  final String originalFilename;
  final String contentType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final String status; // pending | ready | failed
  final DateTime createdAt;

  bool get isReady => status == 'ready';

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      albumId: json['album_id'] as String,
      uploadedBy: json['uploaded_by'] as String?,
      originalFilename: json['original_filename'] as String? ?? '',
      contentType: json['content_type'] as String? ?? '',
      sizeBytes: (json['size_bytes'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class DownloadUrlModel {
  const DownloadUrlModel({required this.url, required this.expiresAt});

  final String url;
  final DateTime expiresAt;

  factory DownloadUrlModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? json;
    return DownloadUrlModel(
      url: data['url'] as String,
      expiresAt: DateTime.parse(data['expires_at'] as String),
    );
  }
}
