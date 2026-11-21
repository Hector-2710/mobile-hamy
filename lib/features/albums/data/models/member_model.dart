class MemberModel {
  const MemberModel({
    required this.albumId,
    required this.userId,
    required this.role,
    required this.status,
    required this.createdAt,
    this.name,
    this.email,
    this.invitedBy,
  });

  final String albumId;
  final String userId;
  final String? name;
  final String? email;
  final String role; // viewer | editor (el owner figura en el álbum)
  final String status; // invited | active | revoked
  final String? invitedBy;
  final DateTime createdAt;

  String get displayName {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return n;
    final e = email?.trim();
    if (e != null && e.isNotEmpty) return e;
    return 'Miembro';
  }

  String get initials {
    final n = name?.trim();
    if (n == null || n.isEmpty) return '?';
    return n[0].toUpperCase();
  }

  bool get isPending => status == 'invited';

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      albumId: json['album_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'active',
      invitedBy: json['invited_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class InvitationModel {
  const InvitationModel({
    required this.albumId,
    required this.albumTitle,
    required this.role,
    required this.createdAt,
    this.invitedByName,
    this.invitedByEmail,
  });

  final String albumId;
  final String albumTitle;
  final String role; // viewer | editor
  final String? invitedByName;
  final String? invitedByEmail;
  final DateTime createdAt;

  String get inviter {
    final n = invitedByName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final e = invitedByEmail?.trim();
    if (e != null && e.isNotEmpty) return e;
    return 'Alguien';
  }

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      albumId: json['album_id'] as String? ?? '',
      albumTitle: json['album_title'] as String? ?? 'Álbum',
      role: json['role'] as String? ?? 'viewer',
      invitedByName: json['invited_by_name'] as String?,
      invitedByEmail: json['invited_by_email'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
