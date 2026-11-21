import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/member_model.dart';
import '../state/album_detail_controller.dart';

/// Hoja inferior con los miembros del álbum: lista, invitación por correo,
/// cambio de rol (dueño) y expulsión o salida del álbum.
class AlbumMembersSheet extends StatefulWidget {
  const AlbumMembersSheet({
    super.key,
    required this.controller,
    required this.currentUserId,
  });

  final AlbumDetailController controller;
  final String? currentUserId;

  static Future<void> show(
    BuildContext context, {
    required AlbumDetailController controller,
    required String? currentUserId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlbumMembersSheet(
        controller: controller,
        currentUserId: currentUserId,
      ),
    );
  }

  @override
  State<AlbumMembersSheet> createState() => _AlbumMembersSheetState();
}

class _AlbumMembersSheetState extends State<AlbumMembersSheet> {
  final _emailController = TextEditingController();
  String _role = 'viewer';
  bool _inviting = false;
  String? _inviteError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  AlbumDetailController get _controller => widget.controller;
  bool get _isOwner => _controller.isOwner;

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _inviteError = 'Escribe el correo de la persona.');
      return;
    }
    setState(() {
      _inviting = true;
      _inviteError = null;
    });
    final error = await _controller.invite(email, role: _role);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _inviting = false;
        _inviteError = error;
      });
      return;
    }
    _emailController.clear();
    setState(() {
      _inviting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invitación enviada a $email.')),
    );
  }

  Future<void> _changeRole(MemberModel member, String role) async {
    final error = await _controller.changeRole(member, role);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _remove(MemberModel member) async {
    final isSelf = member.userId == widget.currentUserId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isSelf ? '¿Salir del álbum?' : '¿Quitar a ${member.displayName}?'),
        content: Text(
          isSelf
              ? 'Dejarás de ver este álbum. Para volver tendrás que recibir '
                    'otra invitación.'
              : 'Dejará de tener acceso al álbum y sus fotos.',
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
            child: Text(isSelf ? 'Salir' : 'Quitar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await _controller.removeMember(member);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (isSelf) {
      // Se salió del álbum: vuelve a la lista de álbumes.
      Navigator.of(context)
        ..pop()
        ..pop();
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${member.displayName} ya no está en el álbum.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = _controller.members;
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
                          Text('Miembros', style: AppTypography.modalTitle),
                          const SizedBox(height: 4),
                          Text(
                            members.length == 1
                                ? '1 persona en este álbum.'
                                : '${members.length} personas en este álbum.',
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
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < members.length; i++) ...[
                        _MemberTile(
                          member: members[i],
                          isOwner: _isOwner,
                          isSelf: members[i].userId == widget.currentUserId,
                          albumOwnerId: _controller.album.ownerId,
                          onRoleChanged: (role) => _changeRole(members[i], role),
                          onRemove: () => _remove(members[i]),
                        ),
                        if (i < members.length - 1)
                          const SizedBox(height: 12),
                      ],
                      if (_isOwner) ...[
                        const SizedBox(height: 24),
                        const Divider(color: AppColors.borderSheet, height: 1),
                        const SizedBox(height: 20),
                        Text(
                          'Invitar a alguien',
                          style: AppTypography.modalTitle.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Debe tener una cuenta en hamy. Le llegará la '
                          'invitación en su pestaña «Invitaciones».',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMeta),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: 'correo@ejemplo.com',
                            isDense: true,
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                            prefixIconColor: AppColors.textMeta,
                            contentPadding: EdgeInsets.fromLTRB(12, 13, 12, 13),
                          ),
                          onChanged: (_) {
                            if (_inviteError != null) {
                              setState(() => _inviteError = null);
                            }
                          },
                          onSubmitted: (_) => _invite(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceAlt,
                                  borderRadius: AppRadii.pill,
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    for (final option in const [
                                      ('viewer', 'Solo ve'),
                                      ('editor', 'Edita'),
                                    ])
                                      Expanded(
                                        child: _RoleButton(
                                          label: option.$2,
                                          selected: _role == option.$1,
                                          onTap: () =>
                                              setState(() => _role = option.$1),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: _inviting ? null : _invite,
                                child: _inviting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Invitar'),
                              ),
                            ),
                          ],
                        ),
                        if (_inviteError != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 15,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _inviteError!,
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

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isOwner,
    required this.isSelf,
    required this.albumOwnerId,
    required this.onRoleChanged,
    required this.onRemove,
  });

  final MemberModel member;
  final bool isOwner;
  final bool isSelf;
  final String albumOwnerId;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRemove;

  bool get _isAlbumOwner => member.userId == albumOwnerId;

  String get _statusLabel {
    if (member.isPending) return 'Pendiente';
    return member.status == 'revoked' ? 'Revocado' : 'Activo';
  }

  @override
  Widget build(BuildContext context) {
    // Solo el dueño gestiona a otros; cualquiera puede salir de su propio
    // miembro (menos el dueño, que no puede salir).
    final canManage = isOwner && !isSelf;
    final canLeave = isSelf && !_isAlbumOwner;
    final roleChip = _isAlbumOwner
        ? const _RoleChip(label: 'Dueño', color: AppColors.cherryDeep)
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _isAlbumOwner ? AppColors.cherry : AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (roleChip != null) ...[
                        const SizedBox(width: 8),
                        roleChip,
                      ],
                    ],
                  ),
                  if (member.email != null &&
                      member.email!.isNotEmpty &&
                      member.name != null &&
                      member.name!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMeta),
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMeta),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (canManage && !_isAlbumOwner)
              PopupMenuButton<String>(
                tooltip: 'Opciones de ${member.displayName}',
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (value) {
                  if (value == 'remove') {
                    onRemove();
                  } else {
                    onRoleChanged(value);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'viewer',
                    child: Row(
                      children: [
                        Icon(
                          member.role == 'viewer'
                              ? Icons.check_rounded
                              : Icons.remove,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Solo ve'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'editor',
                    child: Row(
                      children: [
                        Icon(
                          member.role == 'editor'
                              ? Icons.check_rounded
                              : Icons.remove,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text('Edita'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_remove_outlined,
                          size: 16,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Quitar del álbum',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else if (canLeave)
              IconButton(
                onPressed: onRemove,
                tooltip: 'Salir del álbum',
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.error,
                ),
              )
            else if (!_isAlbumOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  member.role == 'editor' ? 'Edita' : 'Solo ve',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
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
