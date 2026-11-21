import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/albums_repository.dart';
import '../state/album_detail_controller.dart';

/// Acción realizada sobre la foto desde la hoja de detalle.
enum PhotoAction { deleted, coverChanged }

/// Hoja inferior para ver una foto: imagen grande, datos, borrar y portada.
///
/// Devuelve la [PhotoAction] que se completó, o `null` si solo se cerró.
class PhotoDetailSheet extends StatefulWidget {
  const PhotoDetailSheet({
    super.key,
    required this.repository,
    required this.controller,
    required this.photo,
  });

  final AlbumsRepository repository;
  final AlbumDetailController controller;
  final PhotoModel photo;

  static Future<PhotoAction?> show(
    BuildContext context, {
    required AlbumsRepository repository,
    required AlbumDetailController controller,
    required PhotoModel photo,
  }) {
    return showModalBottomSheet<PhotoAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PhotoDetailSheet(
        repository: repository,
        controller: controller,
        photo: photo,
      ),
    );
  }

  @override
  State<PhotoDetailSheet> createState() => _PhotoDetailSheetState();
}

class _PhotoDetailSheetState extends State<PhotoDetailSheet> {
  late final Future<String> _url = _fetchUrl();

  Future<String> _fetchUrl() async {
    final model = await widget.repository.getPhotoDownloadUrl(widget.photo.id);
    return model.url;
  }

  bool get _isCover => widget.controller.album.coverPhotoId == widget.photo.id;

  bool get _canEdit => widget.controller.canEdit;
  bool get _isOwner => widget.controller.isOwner;

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar esta foto?'),
        content: const Text(
          'Se borrará del álbum para todos los miembros. Esta acción no se '
          'puede deshacer.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.textBody),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final ok = await widget.controller.deletePhoto(widget.photo);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(PhotoAction.deleted);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'No se pudo eliminar la foto.',
          ),
        ),
      );
    }
  }

  Future<void> _toggleCover() async {
    final wasCover = _isCover;
    final ok = wasCover
        ? await widget.controller.clearCover()
        : await widget.controller.setCover(widget.photo);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(PhotoAction.coverChanged);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.controller.errorMessage ?? 'No se pudo actualizar la portada.',
          ),
        ),
      );
    }
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) {
      return '${(bytes / 1024).round()} KB';
    }
    return '$bytes B';
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.sheetTop,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Grabber(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foto', style: AppTypography.modalTitle),
                          const SizedBox(height: 4),
                          Text(
                            photo.originalFilename.isNotEmpty
                                ? photo.originalFilename
                                : DateFormatters.formatFullDate(photo.createdAt),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMeta),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.surfaceMuted,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textIconMuted,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSheet, height: 1),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadii.card,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: AppColors.imagePlaceholder,
                            ),
                            child: _FullImage(url: _url),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: AppRadii.card,
                        ),
                        child: Column(
                          children: [
                            _DataRow(
                              icon: Icons.event_rounded,
                              label: 'Fecha',
                              value: '${DateFormatters.formatFullDate(photo.createdAt)} · ${DateFormatters.formatTime(photo.createdAt)}',
                            ),
                            if (photo.width != null && photo.height != null) ...[
                              const SizedBox(height: 10),
                              _DataRow(
                                icon: Icons.aspect_ratio_rounded,
                                label: 'Dimensiones',
                                value: '${photo.width} × ${photo.height} px',
                              ),
                            ],
                            const SizedBox(height: 10),
                            _DataRow(
                              icon: Icons.sd_storage_rounded,
                              label: 'Tamaño',
                              value: _formatSize(photo.sizeBytes),
                            ),
                            if (photo.uploadedBy != null &&
                                photo.uploadedBy!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              _DataRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Subida por',
                                value: photo.uploadedBy!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_canEdit) ...[
                        const SizedBox(height: 20),
                        if (_isOwner || _isCover)
                          SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _toggleCover,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _isCover
                                    ? AppColors.cherryDeep
                                    : AppColors.accent,
                                side: BorderSide(
                                  color: _isCover
                                      ? AppColors.cherryDeep
                                      : AppColors.accent,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.button,
                                ),
                              ),
                              icon: Icon(
                                _isCover
                                    ? Icons.star_outline_rounded
                                    : Icons.star_rounded,
                                size: 18,
                              ),
                              label: Text(
                                _isCover ? 'Quitar como portada' : 'Fijar como portada',
                              ),
                            ),
                          ),
                        if (_isOwner || _isCover) const SizedBox(height: 10),
                        SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _delete,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.button,
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline_rounded, size: 18),
                            label: const Text('Eliminar foto'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullImage extends StatelessWidget {
  const _FullImage({required this.url});

  final Future<String> url;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: url,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textMeta,
              size: 34,
            ),
          );
        }
        return Image.network(
          snapshot.data!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textMeta,
              size: 34,
            ),
          ),
        );
      },
    );
  }
}

class _DataRow extends StatelessWidget {
  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textLabel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(top: 10, bottom: 14),
        decoration: const BoxDecoration(
          color: AppColors.surfaceMutedPressed,
          borderRadius: AppRadii.pill,
        ),
      ),
    );
  }
}
