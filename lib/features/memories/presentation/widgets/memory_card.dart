import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../domain/entities/memory.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
    this.featured = false,
  });

  final Memory memory;
  final VoidCallback onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = memory.imageUrl.isNotEmpty;
    final aspectRatio = hasPhoto
        ? (featured ? 1.5 : 0.78)
        : (featured ? 2.05 : 0.95);

    return Semantics(
      container: true,
      button: true,
      excludeSemantics: true,
      onTap: onTap,
      label:
          '${memory.title}. ${DateFormatters.formatFullDate(memory.date)}. '
          '${memory.location}',
      child: AspectRatio(
        aspectRatio: aspectRatio,
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
                child: memory.imageUrl.isEmpty
                    ? _PendingPhotoCard(memory: memory)
                    : _PhotoCard(memory: memory, featured: featured),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.memory, required this.featured});

  final Memory memory;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'memory-${memory.id}',
          child: _MemoryImage(url: memory.imageUrl),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0x14000000), Color(0xC0000000)],
              stops: [0.3, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                memory.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.cardTitle,
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      featured
                          ? DateFormatters.formatFullDate(memory.date)
                          : DateFormatters.formatShortDate(memory.date),
                      style: AppTypography.metaOnImage,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '·',
                      style: AppTypography.metaOnImage.copyWith(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Text(
                    DateFormatters.formatTime(memory.date),
                    style: AppTypography.metaOnImage,
                  ),
                ],
              ),
              if (featured) ...[
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 13,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        memory.location,
                        style: AppTypography.metaOnImage,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingPhotoCard extends StatelessWidget {
  const _PendingPhotoCard({required this.memory});

  final Memory memory;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.imagePlaceholderAlt, AppColors.imagePlaceholder],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.leafSoft,
                    borderRadius: AppRadii.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco_outlined,
                        size: 12,
                        color: AppColors.leafDeep,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sin foto',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: AppColors.leafDeep),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Icon(
                Icons.photo_outlined,
                size: 26,
                color: AppColors.textMutedSoft.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Text(
              memory.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              '${DateFormatters.formatShortDate(memory.date)} · '
              '${DateFormatters.formatTime(memory.date)}',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMeta),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryImage extends StatelessWidget {
  const _MemoryImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const _ImageSkeleton();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImageSkeleton();
      },
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: AppColors.imagePlaceholder,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textMeta,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.imagePlaceholderAlt, AppColors.imagePlaceholder],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accentSoft,
          ),
        ),
      ),
    );
  }
}
