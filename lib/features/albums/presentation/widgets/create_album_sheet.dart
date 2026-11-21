import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/album_model.dart';

/// Hoja inferior para crear un álbum (título + descripción opcional).
///
/// Devuelve el [AlbumModel] creado, o `null` si se cancela. Los errores del
/// servidor se muestran dentro de la propia hoja.
class CreateAlbumSheet extends StatefulWidget {
  const CreateAlbumSheet({super.key, required this.onCreate});

  /// Crea el álbum en el servidor; devuelve `null` si falló (con el mensaje
  /// ya cargado en el controlador, aquí solo nos interesa el resultado).
  final Future<AlbumModel?> Function(String title, String? description)
  onCreate;

  static Future<AlbumModel?> show(
    BuildContext context, {
    required Future<AlbumModel?> Function(String title, String? description)
    onCreate,
  }) {
    return showModalBottomSheet<AlbumModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateAlbumSheet(onCreate: onCreate),
    );
  }

  @override
  State<CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<CreateAlbumSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Ponle un nombre al álbum.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final description = _descriptionController.text.trim();
    final album = await widget.onCreate(
      title,
      description.isEmpty ? null : description,
    );
    if (!mounted) return;
    if (album == null) {
      setState(() {
        _saving = false;
        _error = 'No se pudo crear el álbum. Inténtalo de nuevo.';
      });
      return;
    }
    Navigator.of(context).pop(album);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
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
                          Text(
                            'Nuevo álbum',
                            style: AppTypography.modalTitle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Un nombre basta; luego podéis invitar a quien '
                            'queráis.',
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
                      Text(
                        'Nombre del álbum',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textLabel,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _titleController,
                        autofocus: true,
                        style: AppTypography.inputSerif,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        maxLength: 150,
                        decoration: const InputDecoration(
                          hintText: 'Ej. Nuestro verano en la costa',
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 14),
                        ),
                        onChanged: (_) {
                          if (_error != null) setState(() => _error = null);
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Descripción (opcional)',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: AppColors.textLabel,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        minLines: 1,
                        maxLength: 2000,
                        decoration: const InputDecoration(
                          hintText: '¿Qué guardaréis en este álbum?',
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 14),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 15,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _error!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderSheet)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        boxShadow: AppShadows.saveButton,
                        borderRadius: AppRadii.button,
                      ),
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Crear álbum'),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
