import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../models/album_model.dart';
import '../models/member_model.dart';
import '../models/pagination_meta.dart';
import '../models/photo_model.dart';
import '../models/upload_ticket_model.dart';

class AlbumsRemoteDatasource {
  AlbumsRemoteDatasource(this._client);

  final ApiClient _client;

  // Dio propio y sin interceptor de auth: la subida va firmada a MinIO.
  final Dio _presignedDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(minutes: 2),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<Paginated<AlbumModel>> listAlbums({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.albums,
      queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => AlbumModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(
      data['meta'] as Map<String, dynamic>? ?? const {},
    );
    return Paginated(items: items, meta: meta);
  }

  Future<AlbumModel> getAlbum(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.album(id),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AlbumModel.fromJson(data);
  }

  Future<AlbumModel> createAlbum({
    required String title,
    String? description,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.albums,
      data: {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AlbumModel.fromJson(data);
  }

  Future<Paginated<PhotoModel>> listPhotos(
    String albumId, {
    int page = 1,
    int perPage = 50,
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.albumPhotos(albumId),
      queryParameters: {'page': page, 'per_page': perPage},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(
      data['meta'] as Map<String, dynamic>? ?? const {},
    );
    return Paginated(items: items, meta: meta);
  }

  Future<DownloadUrlModel> getPhotoDownloadUrl(String photoId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.photoDownloadUrl(photoId),
    );
    return DownloadUrlModel.fromJson(response.data!);
  }

  // ---------------------------------------------------------------- álbumes

  Future<AlbumModel> updateAlbum(
    String id, {
    String? title,
    String? description,
  }) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiEndpoints.album(id),
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AlbumModel.fromJson(data);
  }

  Future<void> deleteAlbum(String id) => _client.delete(ApiEndpoints.album(id));

  Future<AlbumModel> setCover(String albumId, String photoId) async {
    final response = await _client.put<Map<String, dynamic>>(
      ApiEndpoints.albumCover(albumId),
      data: {'photo_id': photoId},
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AlbumModel.fromJson(data);
  }

  Future<AlbumModel> clearCover(String albumId) async {
    final response = await _client.delete<Map<String, dynamic>>(
      ApiEndpoints.albumCover(albumId),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return AlbumModel.fromJson(data);
  }

  // -------------------------------------------------------------- miembros

  Future<List<MemberModel>> listMembers(String albumId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.albumMembers(albumId),
    );
    final items = response.data!['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => MemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemberModel> inviteMember(
    String albumId, {
    String? email,
    String? userId,
    String role = 'viewer',
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.albumMembers(albumId),
      data: {
        if (email != null) 'email': email,
        if (userId != null) 'user_id': userId,
        'role': role,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return MemberModel.fromJson(data);
  }

  Future<void> updateMemberRole(
    String albumId,
    String userId,
    String role,
  ) {
    return _client.patch(
      ApiEndpoints.albumMember(albumId, userId),
      data: {'role': role},
    );
  }

  Future<void> removeMember(String albumId, String userId) {
    return _client.delete(ApiEndpoints.albumMember(albumId, userId));
  }

  // ----------------------------------------------------------- invitaciones

  Future<List<InvitationModel>> listInvitations() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiEndpoints.invitations,
    );
    final items = response.data!['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MemberModel> acceptInvitation(String albumId) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.acceptInvitation(albumId),
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return MemberModel.fromJson(data);
  }

  // ------------------------------------------------------------------ fotos

  /// Solicita el ticket de subida (POST .../photos/uploads).
  Future<UploadTicketModel> initUpload(
    String albumId, {
    required String filename,
    required String contentType,
    required int sizeBytes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.albumPhotoUploads(albumId),
      data: {
        'filename': filename,
        'content_type': contentType,
        'size_bytes': sizeBytes,
      },
    );
    return UploadTicketModel.fromJson(response.data!);
  }

  /// Sube los bytes directamente a MinIO con la URL prefirmada del ticket.
  Future<void> uploadBytes(
    String uploadUrl, {
    required List<int> bytes,
    required String contentType,
  }) async {
    try {
      await _presignedDio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {'Content-Type': contentType},
          contentType: contentType,
        ),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// Confirma la subida (POST .../complete) para que la foto quede `ready`.
  Future<PhotoModel> completeUpload(
    String albumId,
    String photoId, {
    int? width,
    int? height,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiEndpoints.albumPhotoComplete(albumId, photoId),
      data: {
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      },
    );
    final data = response.data!['data'] as Map<String, dynamic>;
    return PhotoModel.fromJson(data);
  }

  Future<void> deletePhoto(String photoId) =>
      _client.delete(ApiEndpoints.photo(photoId));
}
