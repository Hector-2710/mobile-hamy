import 'package:material_ui/material_ui.dart';

import '../../../../core/network/api_error_localizer.dart';
import '../../data/models/album_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/albums_repository.dart';

/// Estado de la lista de álbumes (pestaña «Álbumes»).
class AlbumsController extends ChangeNotifier {
  AlbumsController(this._repository);

  final AlbumsRepository _repository;

  List<AlbumModel> albums = [];
  bool isLoading = false;
  bool isCreating = false;
  String? errorMessage;
  String search = '';

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final result = await _repository.listAlbums(perPage: 100);
      albums = result.items;
      errorMessage = null;
    } catch (e) {
      errorMessage = localizedApiError(e);
    }
    isLoading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  List<AlbumModel> get visibleAlbums {
    final query = search.trim().toLowerCase();
    if (query.isEmpty) return albums;
    return albums.where((a) {
      final title = a.title.toLowerCase();
      final description = (a.description ?? '').toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }

  /// Crea un álbum; devuelve `null` si hubo error (queda en [errorMessage]).
  Future<AlbumModel?> create(String title, {String? description}) async {
    isCreating = true;
    errorMessage = null;
    notifyListeners();
    try {
      final album = await _repository.createAlbum(
        title: title,
        description: description,
      );
      albums = [...albums, album];
      isCreating = false;
      notifyListeners();
      return album;
    } catch (e) {
      errorMessage = localizedApiError(e);
      isCreating = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> remove(AlbumModel album) async {
    await _repository.deleteAlbum(album.id);
    albums = albums.where((a) => a.id != album.id).toList();
    notifyListeners();
  }
}

/// Estado de las invitaciones pendientes (pestaña «Invitaciones»).
class InvitationsController extends ChangeNotifier {
  InvitationsController(this._repository);

  final AlbumsRepository _repository;

  List<InvitationModel> invitations = [];
  bool isLoading = false;
  String? errorMessage;
  Set<String> accepting = {};

  int get pendingCount => invitations.length;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      invitations = await _repository.listInvitations();
      errorMessage = null;
    } catch (e) {
      errorMessage = localizedApiError(e);
    }
    isLoading = false;
    notifyListeners();
  }

  /// Acepta una invitación; `true` si salió bien.
  Future<bool> accept(String albumId) async {
    accepting = {...accepting, albumId};
    notifyListeners();
    try {
      await _repository.acceptInvitation(albumId);
      invitations = invitations.where((i) => i.albumId != albumId).toList();
      accepting = {...accepting}..remove(albumId);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = localizedApiError(e);
      accepting = {...accepting}..remove(albumId);
      notifyListeners();
      return false;
    }
  }
}
