import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/network/api_error_localizer.dart';
import '../../data/models/album_model.dart';
import '../../data/models/member_model.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/albums_repository.dart';

/// Vista activa de la cronología del álbum.
enum AlbumView { weeks, months, years }

/// Grupo de fotos de la cronología (semana, mes o año).
class PhotoGroup {
  const PhotoGroup({required this.label, required this.photos});

  final String label;
  final List<PhotoModel> photos;
}

/// Estado del detalle de álbum: fotos, vista, subida, portada y miembros.
class AlbumDetailController extends ChangeNotifier {
  AlbumDetailController(this._repository, this.album);

  final AlbumsRepository _repository;

  AlbumModel album;
  List<PhotoModel> photos = [];
  List<MemberModel> members = [];
  AlbumView view = AlbumView.months;

  bool isLoading = false;
  bool isUploading = false;
  double uploadProgress = 0;
  String? errorMessage;

  static const int _maxUploadBytes = 25 * 1024 * 1024; // límite de la API

  bool get canEdit => album.canEdit;
  bool get isOwner => album.isOwner;

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }
    try {
      final results = await Future.wait<dynamic>([
        _repository.getAlbum(album.id),
        _repository.listPhotos(album.id, perPage: 100),
        _repository.listMembers(album.id),
      ]);
      album = results[0] as AlbumModel;
      photos = (results[1] as dynamic).items as List<PhotoModel>;
      members = results[2] as List<MemberModel>;
      errorMessage = null;
    } catch (e) {
      errorMessage = localizedApiError(e);
    }
    isLoading = false;
    notifyListeners();
  }

  void setView(AlbumView value) {
    if (view == value) return;
    view = value;
    notifyListeners();
  }

  // ------------------------------------------------------------ cronología

  /// Agrupa las fotos (más recientes primero) según la vista activa.
  List<PhotoGroup> get groups {
    final sorted = [...photos]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final map = <String, List<PhotoModel>>{};
    final labels = <String, String>{};

    for (final photo in sorted) {
      final date = photo.createdAt;
      final String key;
      final String label;
      switch (view) {
        case AlbumView.years:
          key = '${date.year}';
          label = key;
        case AlbumView.months:
          key = '${date.year}-${date.month}';
          label = _monthLabel(date);
        case AlbumView.weeks:
          final monday = _mondayOf(date);
          key = '${monday.year}-${monday.month}-${monday.day}';
          label = _weekLabel(monday);
      }
      map.putIfAbsent(key, () => []).add(photo);
      labels[key] = label;
    }

    return [
      for (final entry in map.entries)
        PhotoGroup(label: labels[entry.key]!, photos: entry.value),
    ];
  }

  static DateTime _mondayOf(DateTime date) {
    final daysSinceMonday = (date.weekday + 6) % 7;
    return DateTime(date.year, date.month, date.day - daysSinceMonday);
  }

  static String _monthLabel(DateTime date) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String _weekLabel(DateTime monday) {
    final sunday = monday.add(const Duration(days: 6));
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    final sameMonth = monday.month == sunday.month && monday.year == sunday.year;
    if (sameMonth) {
      return '${monday.day}–${sunday.day} ${months[monday.month - 1]} '
          '${monday.year}';
    }
    return '${monday.day} ${months[monday.month - 1]} – '
        '${sunday.day} ${months[sunday.month - 1]} ${sunday.year}';
  }

  // --------------------------------------------------------------- subida

  /// Sube las fotos elegidas. Devuelve el número de fotos subidas con éxito.
  Future<int> uploadPhotos(List<XFile> files) async {
    if (files.isEmpty || isUploading) return 0;
    isUploading = true;
    uploadProgress = 0;
    errorMessage = null;
    notifyListeners();

    var uploaded = 0;
    var processed = 0;
    for (final file in files) {
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isEmpty || bytes.length > _maxUploadBytes) {
          errorMessage = bytes.isEmpty
              ? 'No se pudo leer «${file.name}».'
              : '«${file.name}» pesa más de 25 MB y no se subió.';
          processed++;
          uploadProgress = processed / files.length;
          notifyListeners();
          continue;
        }

        final contentType = _contentTypeFor(file.name);
        final ticket = await _repository.initUpload(
          album.id,
          filename: file.name,
          contentType: contentType,
          sizeBytes: bytes.length,
        );
        await _repository.uploadBytes(
          ticket.uploadUrl,
          bytes: bytes,
          contentType: contentType,
        );
        final dimensions = await _decodeDimensions(bytes);
        await _repository.completeUpload(
          album.id,
          ticket.photoId,
          width: dimensions?.$1,
          height: dimensions?.$2,
        );
        uploaded++;
      } catch (e) {
        errorMessage = localizedApiError(e);
      }
      processed++;
      uploadProgress = processed / files.length;
      notifyListeners();
    }

    isUploading = false;
    uploadProgress = 0;
    // Recarga la cronología con las fotos nuevas.
    await load(silent: true);
    if (uploaded > 0) errorMessage = null;
    notifyListeners();
    return uploaded;
  }

  static String _contentTypeFor(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }

  Future<(int, int)?> _decodeDimensions(Uint8List bytes) async {
    try {
      // decodeImageFromList está en material_ui (pintura de Flutter).
      final image = await decodeImageFromList(bytes);
      final size = (image.width, image.height);
      image.dispose();
      return size;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------- fotos / cover

  Future<bool> deletePhoto(PhotoModel photo) async {
    try {
      await _repository.deletePhoto(photo.id);
      photos = photos.where((p) => p.id != photo.id).toList();
      if (album.coverPhotoId == photo.id) {
        album = AlbumModel(
          id: album.id,
          ownerId: album.ownerId,
          title: album.title,
          description: album.description,
          coverPhotoId: null,
          accessRole: album.accessRole,
          createdAt: album.createdAt,
          updatedAt: album.updatedAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = localizedApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> setCover(PhotoModel photo) async {
    try {
      album = await _repository.setCover(album.id, photo.id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = localizedApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearCover() async {
    try {
      album = await _repository.clearCover(album.id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = localizedApiError(e);
      notifyListeners();
      return false;
    }
  }

  Future<DownloadUrlModel> photoUrl(String photoId) {
    return _repository.getPhotoDownloadUrl(photoId);
  }

  // ------------------------------------------------------------ edición

  /// Actualiza título y/o descripción; devuelve `null` si salió bien o el
  /// mensaje de error si falló.
  Future<String?> updateDetails({
    required String title,
    String? description,
  }) async {
    try {
      album = await _repository.updateAlbum(
        album.id,
        title: title,
        description: description,
      );
      notifyListeners();
      return null;
    } catch (e) {
      final message = localizedApiError(e);
      notifyListeners();
      return message;
    }
  }

  // -------------------------------------------------------------- miembros

  Future<String?> invite(String email, {String role = 'viewer'}) async {
    try {
      final member = await _repository.inviteMember(
        album.id,
        email: email,
        role: role,
      );
      members = [...members, member];
      notifyListeners();
      return null;
    } catch (e) {
      final message = localizedApiError(e);
      notifyListeners();
      return message;
    }
  }

  Future<String?> changeRole(MemberModel member, String role) async {
    try {
      await _repository.updateMemberRole(album.id, member.userId, role);
      members = [
        for (final m in members)
          if (m.userId == member.userId)
            MemberModel(
              albumId: m.albumId,
              userId: m.userId,
              name: m.name,
              email: m.email,
              role: role,
              status: m.status,
              invitedBy: m.invitedBy,
              createdAt: m.createdAt,
            )
          else
            m,
      ];
      notifyListeners();
      return null;
    } catch (e) {
      final message = localizedApiError(e);
      notifyListeners();
      return message;
    }
  }

  Future<String?> removeMember(MemberModel member) async {
    try {
      await _repository.removeMember(album.id, member.userId);
      members = members.where((m) => m.userId != member.userId).toList();
      notifyListeners();
      return null;
    } catch (e) {
      final message = localizedApiError(e);
      notifyListeners();
      return message;
    }
  }
}
