import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/models/album_model.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/albums_repository.dart';
import '../state/album_detail_controller.dart';
import '../widgets/album_members_sheet.dart';
import '../widgets/edit_album_sheet.dart';
import '../widgets/photo_detail_sheet.dart';
import '../widgets/photo_thumb.dart';

/// Detalle de álbum: cronología con vistas semanas/meses/años, subida de
/// fotos, portada, edición y miembros.
class AlbumDetailPage extends StatefulWidget {
  const AlbumDetailPage({
    super.key,
    required this.controllerAlbum,
    required this.currentUserId,
  });

  final AlbumModel controllerAlbum;
  final String? currentUserId;

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late final AlbumDetailController _controller;
  late final AlbumsRepository _repository;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppScope es un inherited widget: hay que leerlo aquí, no en initState.
    if (_initialized) return;
    _initialized = true;
    _repository = AppScope.albumsOf(context);
    _controller = AlbumDetailController(_repository, widget.controllerAlbum)
      ..addListener(_onChanged)
      ..load();
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickAndUpload() async {
    if (!_controller.canEdit) return;
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final uploaded = await _controller.uploadPhotos(files);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            uploaded == files.length
                ? uploaded == 1
                      ? '1 foto subida al álbum.'
                      : '$uploaded fotos subidas al álbum.'
                : uploaded == 0
                    ? 'No se pudo subir ninguna foto.'
                    : 'Se subieron $uploaded de ${files.length} fotos.',
          ),
        ),
      );
  }

  Future<void> _openPhoto(PhotoModel photo) async {
    final action = await PhotoDetailSheet.show(
      context,
      repository: _repository,
      controller: _controller,
      photo: photo,
    );
    if (!mounted || action == null) return;
    if (action == PhotoAction.deleted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Foto eliminada.')));
    } else if (action == PhotoAction.coverChanged) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Portada actualizada.')));
    }
  }

  Future<void> _albumMenu(String value) async {
    switch (value) {
      case 'edit':
        await EditAlbumSheet.show(context, controller: _controller);
      case 'members':
        await AlbumMembersSheet.show(
          context,
          controller: _controller,
          currentUserId: widget.currentUserId,
        );
      case 'cover':
        if (_controller.album.coverPhotoId != null) {
          await _controller.clearCover();
        }
      case 'delete':
        await _confirmDeleteAlbum();
    }
  }

  Future<void> _confirmDeleteAlbum() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Eliminar este álbum?'),
        content: const Text(
          'Se borrarán sus fotos y sus miembros. Esta acción no se puede '
          'deshacer.',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textBody,
            ),
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
    try {
      await _repository.deleteAlbum(_controller.album.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Álbum eliminado.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el álbum.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final album = _controller.album;
    final groups = _controller.groups;
    final photoCount = _controller.photos.length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ColoredBox(
            color: AppColors.surface,
            child: RefreshIndicator(
              color: AppColors.accent,
              onRefresh: () => _controller.load(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _Header(
                      album: album,
                      controller: _controller,
                      photoCount: photoCount,
                      onBack: () => Navigator.of(context).pop(),
                      onMenu: _albumMenu,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ViewSwitcher(
                      view: _controller.view,
                      onChanged: _controller.setView,
                    ),
                  ),
                  if (_controller.errorMessage != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: _ErrorBanner(message: _controller.errorMessage!),
                      ),
                    ),
                  if (_controller.isLoading && _controller.photos.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      ),
                    )
                  else if (_controller.photos.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyPhotos(
                        canEdit: _controller.canEdit,
                        onUpload: _pickAndUpload,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          for (var i = 0; i < groups.length; i++) ...[
                            _GroupHeader(
                              label: groups[i].label,
                              count: groups[i].photos.length,
                              index: i,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _PhotoGrid(
                              group: groups[i],
                              repository: _repository,
                              coverPhotoId: album.coverPhotoId,
                              onPhotoTap: _openPhoto,
                            ),
                            if (i < groups.length - 1)
                              const SizedBox(height: AppSpacing.section),
                          ],
                        ]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _controller.canEdit
          ? FloatingActionButton.extended(
              onPressed: _controller.isUploading ? null : _pickAndUpload,
              tooltip: 'Agregar fotos al álbum',
              icon: _controller.isUploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _controller.isUploading
                    ? 'Subiendo ${(100 * _controller.uploadProgress).round()}%'
                    : 'Agregar fotos',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.album,
    required this.controller,
    required this.photoCount,
    required this.onBack,
    required this.onMenu,
  });

  final AlbumModel album;
  final AlbumDetailController controller;
  final int photoCount;
  final VoidCallback onBack;
  final ValueChanged<String> onMenu;

  String get _roleLabel => switch (album.accessRole) {
    'owner' => 'Tu álbum',
    'editor' => 'Puedes editar',
    _ => 'Solo lectura',
  };

  @override
  Widget build(BuildContext context) {
    final memberCount = controller.members.length;
    final summary = <String>[
      photoCount == 1 ? '1 foto' : '$photoCount fotos',
      if (memberCount > 0)
        memberCount == 1 ? '1 miembro' : '$memberCount miembros',
      _roleLabel,
    ].join(' · ');

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  tooltip: 'Volver',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  tooltip: 'Opciones del álbum',
                  icon: const Icon(Icons.more_horiz_rounded),
                  onSelected: onMenu,
                  itemBuilder: (context) => [
                    if (controller.canEdit)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Editar álbum'),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'members',
                      child: Row(
                        children: [
                          Icon(Icons.group_outlined, size: 18),
                          SizedBox(width: 10),
                          Text('Miembros'),
                        ],
                      ),
                    ),
                    if (controller.isOwner &&
                        album.coverPhotoId != null)
                      const PopupMenuItem<String>(
                        value: 'cover',
                        child: Row(
                          children: [
                            Icon(Icons.image_not_supported_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Quitar portada'),
                          ],
                        ),
                      ),
                    if (controller.isOwner)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Eliminar álbum',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (album.description != null &&
                      album.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      album.description!.trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textMeta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.view, required this.onChanged});

  final AlbumView view;
  final ValueChanged<AlbumView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppRadii.pill,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            for (final option in AlbumView.values)
              Expanded(
                child: _ViewButton(
                  label: switch (option) {
                    AlbumView.weeks => 'Semanas',
                    AlbumView.months => 'Meses',
                    AlbumView.years => 'Años',
                  },
                  selected: view == option,
                  onTap: () => onChanged(option),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.accent : Colors.transparent,
      borderRadius: AppRadii.pill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : AppColors.textBody,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.label,
    required this.count,
    required this.index,
  });

  final String label;
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dotColor = index == 0 ? AppColors.accent : AppColors.leaf;

    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor.withValues(alpha: 0.14),
          ),
          alignment: Alignment.center,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: AppColors.borderSoft)),
        const SizedBox(width: 12),
        Text(
          count == 1 ? '1 foto' : '$count fotos',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textMeta),
        ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.group,
    required this.repository,
    required this.coverPhotoId,
    required this.onPhotoTap,
  });

  final PhotoGroup group;
  final AlbumsRepository repository;
  final String? coverPhotoId;
  final ValueChanged<PhotoModel> onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final photos = group.photos;
    final rows = <Widget>[];
    var i = 0;
    while (i < photos.length) {
      final left = photos[i];
      final right = i + 1 < photos.length ? photos[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _PhotoTile(
                photo: left,
                repository: repository,
                isCover: left.id == coverPhotoId,
                onTap: () => onPhotoTap(left),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: right != null
                  ? _PhotoTile(
                      photo: right,
                      repository: repository,
                      isCover: right.id == coverPhotoId,
                      onTap: () => onPhotoTap(right),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
      i += right != null ? 2 : 1;
      if (i < photos.length) rows.add(const SizedBox(height: AppSpacing.md));
    }
    return Column(children: rows);
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.repository,
    required this.isCover,
    required this.onTap,
  });

  final PhotoModel photo;
  final AlbumsRepository repository;
  final bool isCover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.92,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: AppRadii.card,
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: AppRadii.card,
          child: Material(
            color: AppColors.imagePlaceholder,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white.withValues(alpha: 0.12),
              highlightColor: Colors.white.withValues(alpha: 0.06),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PhotoThumb(repository: repository, photo: photo),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x00000000),
                          Color(0x0D000000),
                          Color(0x99000000),
                        ],
                        stops: [0.55, 0.75, 1.0],
                      ),
                    ),
                  ),
                  if (isCover)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: _CoverBadge(),
                    ),
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Text(
                      '${DateFormatters.formatShortDate(photo.createdAt)} · '
                      '${DateFormatters.formatTime(photo.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metaOnImage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverBadge extends StatelessWidget {
  const _CoverBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: AppRadii.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Portada',
            style: AppTypography.metaOnImage.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPhotos extends StatelessWidget {
  const _EmptyPhotos({required this.canEdit, required this.onUpload});

  final bool canEdit;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: AppShadows.logo,
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.cherry,
                size: 30,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'El álbum está esperando\nsu primera foto.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              canEdit
                  ? 'Toca «Agregar fotos» para subir imágenes desde tu '
                        'galería.'
                  : 'Las fotos aparecerán aquí cuando las suba alguien con '
                        'permiso de edición.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (canEdit) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Agregar fotos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 17,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
