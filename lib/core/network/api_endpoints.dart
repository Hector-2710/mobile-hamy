/// Endpoints de api-hamy (prefijo /api/v1).
abstract final class ApiEndpoints {
  static const String v1 = '/api/v1';

  // Auth
  static const String register = '$v1/auth/register';
  static const String login = '$v1/auth/login';
  static const String me = '$v1/auth/me';

  // Albums
  static const String albums = '$v1/albums';
  static String album(String id) => '$v1/albums/$id';
  static String albumCover(String id) => '$v1/albums/$id/cover';
  static String albumMembers(String id) => '$v1/albums/$id/members';
  static String albumMember(String id, String userId) =>
      '$v1/albums/$id/members/$userId';
  static String albumPhotos(String id) => '$v1/albums/$id/photos';
  static String albumPhotoUploads(String id) => '$v1/albums/$id/photos/uploads';
  static String albumPhotoComplete(String id, String photoId) =>
      '$v1/albums/$id/photos/$photoId/complete';

  // Photos
  static String photoDownloadUrl(String id) => '$v1/photos/$id/download-url';
  static String photo(String id) => '$v1/photos/$id';

  // Invitations
  static const String invitations = '$v1/invitations';
  static String acceptInvitation(String albumId) =>
      '$v1/invitations/$albumId/accept';
}
