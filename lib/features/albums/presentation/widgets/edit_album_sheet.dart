import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../state/album_detail_controller.dart';

/// Hoja inferior para editar título y descripción de un álbum.
///
/// Los errores del servidor se muestran dentro de la propia hoja.
class EditAlbumSheet extends StatefulWidget {
  const EditAlbumSheet({super.key, required this.controller});

  final AlbumDetailController controller;

  static Future<bool> show(
    BuildContext context, {
    required AlbumDetailController controller,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAlbumSheet(controller: controller),
    ).then((saved) => saved ?? false);
  }

  @override
  State<EditAlbumSheet> createState() => _EditAlbumSheetState();
}

class _EditAlbumSheetState extends State<EditAlbumSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final album = widget.controller.album;
    _titleController = TextEditingController(text: album.title);
    _descriptionController = TextEditingController(text: album.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'El álbum necesita un nombre.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final description = _descriptionController.text.trim();
    final error = await widget.controller.updateDetails(
      title: title,
      description: description.isEmpty ? null : description,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
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
                          Text('Editar álbum', style: AppTypography.modalTitle),
                          const SizedBox(height: 4),
                          Text(
                            'El título y la descripción que ve todo el álbum.',
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
                child: DecoratedBox(
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
                              Text('Guardar cambios'),
                              SizedBox(width: 8),
                              Icon(Icons.check_rounded, size: 18),
                            ],
                          ),
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
