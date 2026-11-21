import '../datasources/albums_remote_datasource.dart';
import '../models/album_model.dart';
import '../models/member_model.dart';
import '../models/pagination_meta.dart';
import '../models/photo_model.dart';
import '../models/upload_ticket_model.dart';

class AlbumsRepository {
  AlbumsRepository(this._remote);

  final AlbumsRemoteDatasource _remote;

  Future<Paginated<AlbumModel>> listAlbums({int page = 1, int perPage = 20}) {
    return _remote.listAlbums(page: page, perPage: perPage);
  }

  Future<AlbumModel> getAlbum(String id) => _remote.getAlbum(id);

  Future<AlbumModel> createAlbum({required String title, String? description}) {
    return _remote.createAlbum(title: title, description: description);
  }

  Future<AlbumModel> updateAlbum(
    String id, {
    String? title,
    String? description,
  }) {
    return _remote.updateAlbum(id, title: title, description: description);
  }

  Future<void> deleteAlbum(String id) => _remote.deleteAlbum(id);

  Future<AlbumModel> setCover(String albumId, String photoId) {
    return _remote.setCover(albumId, photoId);
  }

  Future<AlbumModel> clearCover(String albumId) => _remote.clearCover(albumId);

  Future<Paginated<PhotoModel>> listPhotos(
    String albumId, {
    int page = 1,
    int perPage = 50,
  }) {
    return _remote.listPhotos(albumId, page: page, perPage: perPage);
  }

  Future<DownloadUrlModel> getPhotoDownloadUrl(String photoId) {
    return _remote.getPhotoDownloadUrl(photoId);
  }

  // -------------------------------------------------------------- miembros

  Future<List<MemberModel>> listMembers(String albumId) {
    return _remote.listMembers(albumId);
  }

  Future<MemberModel> inviteMember(
    String albumId, {
    String? email,
    String role = 'viewer',
  }) {
    return _remote.inviteMember(albumId, email: email, role: role);
  }

  Future<void> updateMemberRole(String albumId, String userId, String role) {
    return _remote.updateMemberRole(albumId, userId, role);
  }

  Future<void> removeMember(String albumId, String userId) {
    return _remote.removeMember(albumId, userId);
  }

  // ----------------------------------------------------------- invitaciones

  Future<List<InvitationModel>> listInvitations() {
    return _remote.listInvitations();
  }

  Future<MemberModel> acceptInvitation(String albumId) {
    return _remote.acceptInvitation(albumId);
  }

  // ------------------------------------------------------- subida de fotos

  Future<UploadTicketModel> initUpload(
    String albumId, {
    required String filename,
    required String contentType,
    required int sizeBytes,
  }) {
    return _remote.initUpload(
      albumId,
      filename: filename,
      contentType: contentType,
      sizeBytes: sizeBytes,
    );
  }

  Future<void> uploadBytes(
    String uploadUrl, {
    required List<int> bytes,
    required String contentType,
  }) {
    return _remote.uploadBytes(
      uploadUrl,
      bytes: bytes,
      contentType: contentType,
    );
  }

  Future<PhotoModel> completeUpload(
    String albumId,
    String photoId, {
    int? width,
    int? height,
  }) {
    return _remote.completeUpload(
      albumId,
      photoId,
      width: width,
      height: height,
    );
  }

  Future<void> deletePhoto(String photoId) => _remote.deletePhoto(photoId);
}
