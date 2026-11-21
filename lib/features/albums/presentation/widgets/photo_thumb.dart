import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/albums_repository.dart';

/// Miniatura de foto que resuelve la URL prefirmada de descarga.
///
/// La URL se pide una sola vez por widget (se reutiliza entre rebuilds) y se
/// vuelve a pedir solo si el widget se reconstruye con otra foto.
class PhotoThumb extends StatefulWidget {
  const PhotoThumb({
    super.key,
    required this.repository,
    required this.photo,
    this.fit = BoxFit.cover,
  });

  final AlbumsRepository repository;
  final PhotoModel photo;
  final BoxFit fit;

  @override
  State<PhotoThumb> createState() => _PhotoThumbState();
}

class _PhotoThumbState extends State<PhotoThumb> {
  late Future<String> _url = _fetch();

  Future<String> _fetch() async {
    final model = await widget.repository.getPhotoDownloadUrl(widget.photo.id);
    return model.url;
  }

  @override
  void didUpdateWidget(PhotoThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.id != widget.photo.id) {
      _url = _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _url,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _Skeleton();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const _Failed();
        }
        return Image.network(
          snapshot.data!,
          fit: widget.fit,
          errorBuilder: (context, error, stack) => const _Failed(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const _Skeleton();
          },
        );
      },
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

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

class _Failed extends StatelessWidget {
  const _Failed();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.textMeta,
          size: 26,
        ),
      ),
    );
  }
}
