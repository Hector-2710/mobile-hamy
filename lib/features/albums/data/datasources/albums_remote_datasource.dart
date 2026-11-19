import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/album_model.dart';
import '../models/pagination_meta.dart';
import '../models/photo_model.dart';

class AlbumsRemoteDatasource {
  AlbumsRemoteDatasource(this._client);

  final ApiClient _client;

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
}
