import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../data/models/album_model.dart';
import '../pages/album_detail_page.dart';
import '../state/albums_controller.dart';
import '../widgets/create_album_sheet.dart';

/// Pestaña «Álbumes»: lista de álbumes, búsqueda y creación.
class AlbumsTab extends StatefulWidget {
  const AlbumsTab({
    super.key,
    required this.controller,
    required this.onJoinedAlbum,
  });

  final AlbumsController controller;

  /// Se llama tras crear un álbum (para refrescar listas externas si hace falta).
  final VoidCallback onJoinedAlbum;

  @override
  State<AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<AlbumsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openCreateSheet() async {
    final album = await CreateAlbumSheet.show(
      context,
      onCreate: (title, description) => widget.controller.create(
        title,
        description: description,
      ),
    );
    if (album == null || !mounted) return;
    widget.onJoinedAlbum();
    await _openAlbum(album);
  }

  Future<void> _openAlbum(AlbumModel album) async {
    final userId = AppScope.of(context).user?.id;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AlbumDetailPage(
          controllerAlbum: album,
          currentUserId: userId,
        ),
      ),
    );
    // Vuelve de un álbum: refresca portadas/contadores en silencio.
    if (mounted) widget.controller.load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final albums = controller.visibleAlbums;
    final user = AppScope.of(context).user;
    final initial = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'h';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ColoredBox(
          color: AppColors.surface,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () => controller.load(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    initial: initial,
                    controller: controller,
                    onCreate: _openCreateSheet,
                  ),
                ),
                if (controller.isLoading && controller.albums.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _LoadingState(),
                  )
                else if (controller.errorMessage != null &&
                    controller.albums.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: controller.errorMessage!,
                      onRetry: () => controller.load(),
                    ),
                  )
                else if (albums.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      hasSearch: controller.search.trim().isNotEmpty,
                      onCreate: _openCreateSheet,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (var i = 0; i < albums.length; i++) ...[
                          _AlbumCard(
                            album: albums[i],
                            onTap: () => _openAlbum(albums[i]),
                          ),
                          if (i < albums.length - 1)
                            const SizedBox(height: AppSpacing.lg),
                        ],
                      ]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.initial,
    required this.controller,
    required this.onCreate,
  });

  final String initial;
  final AlbumsController controller;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final count = controller.albums.length;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 38,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 2,
                        child: _AvatarCircle(
                          label: initial,
                          color: AppColors.accent,
                        ),
                      ),
                      const Positioned(
                        left: 22,
                        top: 2,
                        child: _AvatarCircle(
                          icon: Icons.favorite_rounded,
                          color: AppColors.leaf,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'hamy',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        count == 1 ? '1 álbum' : '$count álbumes',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMeta),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: IconButton(
                    onPressed: onCreate,
                    tooltip: 'Crear álbum',
                    icon: const Icon(Icons.add_rounded, size: 26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextField(
              style: Theme.of(context).textTheme.bodyLarge,
              textInputAction: TextInputAction.search,
              onChanged: controller.setSearch,
              decoration: InputDecoration(
                hintText: 'Buscar álbum...',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                prefixIconColor: AppColors.textMeta,
                contentPadding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
                suffixIcon: controller.search.isNotEmpty
                    ? IconButton(
                        onPressed: () => controller.setSearch(''),
                        tooltip: 'Borrar búsqueda',
                        icon: const Icon(Icons.close_rounded, size: 18),
                      )
                    : null,
                suffixIconColor: AppColors.textMeta,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album, required this.onTap});

  final AlbumModel album;
  final VoidCallback onTap;

  String get _roleLabel => switch (album.accessRole) {
    'owner' => 'Tu álbum',
    'editor' => 'Puedes editar',
    _ => 'Solo lectura',
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.card,
        child: Material(
          color: AppColors.surfaceAlt,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AlbumThumb(),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (album.description != null &&
                            album.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            album.description!.trim(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMeta),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: album.isOwner
                                    ? AppColors.blush
                                    : AppColors.leafSoft,
                                borderRadius: AppRadii.pill,
                              ),
                              child: Text(
                                _roleLabel,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: album.isOwner
                                          ? AppColors.cherryDeep
                                          : AppColors.leafDeep,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                DateFormatters.formatShortDate(
                                  album.updatedAt,
                                ),
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.metaOnLight,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.textMutedSoft,
                            ),
                          ],
                        ),
                      ],
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

class _AlbumThumb extends StatelessWidget {
  const _AlbumThumb();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Center(
        child: Icon(
          Icons.photo_library_outlined,
          color: AppColors.cherry,
          size: 26,
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.label, this.icon, required this.color});

  final String? label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: 14)
          : Text(
              label ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: AppColors.textMutedSoft,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onCreate});

  final bool hasSearch;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88),
            const SizedBox(height: 22),
            Text(
              hasSearch
                  ? 'Ningún álbum coincide\ncon tu búsqueda.'
                  : 'Aún no tienes álbumes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              hasSearch
                  ? 'Prueba con otra palabra o borra la búsqueda.'
                  : 'Crea tu primer álbum y empieza a guardar los momentos '
                        'que querréis recordar.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Crear álbum'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
