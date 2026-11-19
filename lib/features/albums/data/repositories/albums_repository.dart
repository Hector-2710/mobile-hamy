import '../datasources/albums_remote_datasource.dart';
import '../models/album_model.dart';
import '../models/pagination_meta.dart';
import '../models/photo_model.dart';

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
}
