class AlbumModel {
  const AlbumModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.accessRole,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.coverPhotoId,
  });

  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final String? coverPhotoId;
  final String accessRole; // owner | editor | viewer
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get canEdit => accessRole == 'owner' || accessRole == 'editor';
  bool get isOwner => accessRole == 'owner';

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      coverPhotoId: json['cover_photo_id'] as String?,
      accessRole: json['access_role'] as String? ?? 'viewer',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
