import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../data/models/member_model.dart';
import '../state/albums_controller.dart';

/// Pestaña «Invitaciones»: álbumes a los que te han invitado y aceptarlos.
class InvitationsTab extends StatefulWidget {
  const InvitationsTab({
    super.key,
    required this.controller,
    required this.onAccepted,
  });

  final InvitationsController controller;

  /// Se llama tras aceptar una invitación (para refrescar la lista de álbumes).
  final VoidCallback onAccepted;

  @override
  State<InvitationsTab> createState() => _InvitationsTabState();
}

class _InvitationsTabState extends State<InvitationsTab> {
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

  Future<void> _accept(InvitationModel invitation) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await widget.controller.accept(invitation.albumId);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Ya formas parte de «${invitation.albumTitle}».'
                : widget.controller.errorMessage ??
                    'No se pudo aceptar la invitación.',
          ),
        ),
      );
    if (ok) widget.onAccepted();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final invitations = controller.invitations;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ColoredBox(
          color: AppColors.surface,
          child: RefreshIndicator(
            color: AppColors.accent,
            onRefresh: controller.load,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                if (controller.isLoading && invitations.isEmpty)
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
                else if (controller.errorMessage != null && invitations.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: controller.errorMessage!,
                      onRetry: controller.load,
                    ),
                  )
                else if (invitations.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (var i = 0; i < invitations.length; i++) ...[
                          _InvitationCard(
                            invitation: invitations[i],
                            accepting: controller.accepting
                                .contains(invitations[i].albumId),
                            onAccept: () => _accept(invitations[i]),
                          ),
                          if (i < invitations.length - 1)
                            const SizedBox(height: 14),
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitaciones', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Álbumes de otras personas a los que puedes unirte.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.accepting,
    required this.onAccept,
  });

  final InvitationModel invitation;
  final bool accepting;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final roleLabel = invitation.role == 'editor'
        ? 'Podrás añadir y quitar fotos'
        : 'Solo podrás ver las fotos';

    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.card,
        child: Material(
          color: AppColors.surfaceAlt,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mail_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation.albumTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${invitation.inviter} te invitó · '
                            '${DateFormatters.formatShortDate(invitation.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMeta),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: invitation.role == 'editor'
                            ? AppColors.leafSoft
                            : AppColors.blush,
                        borderRadius: AppRadii.pill,
                      ),
                      child: Text(
                        invitation.role == 'editor' ? 'Editor' : 'Solo lectura',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: invitation.role == 'editor'
                              ? AppColors.leafDeep
                              : AppColors.cherryDeep,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        roleLabel,
                        style: AppTypography.metaOnLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton(
                          onPressed: accepting ? null : onAccept,
                          child: accepting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Aceptar invitación'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              'No tienes invitaciones\npendientes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Cuando alguien te invite a un álbum, aparecerá aquí para que '
              'aces de un toque.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
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
