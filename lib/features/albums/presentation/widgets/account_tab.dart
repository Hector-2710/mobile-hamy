import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/utils/date_formatters.dart';

/// Pestaña «Cuenta»: datos del usuario, ajustes de la app y cierre de sesión.
class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a entrar con tu correo.'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.textBody),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loggingOut = true);
    // El AuthGate observa el estado y vuelve al login al detectar el cambio.
    await AppScope.of(context).logout();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context);
    final user = auth.user;
    final initial = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : 'h';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ColoredBox(
          color: AppColors.surface,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cuenta',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          borderRadius: AppRadii.card,
                          boxShadow: AppShadows.card,
                        ),
                        child: ClipRRect(
                          borderRadius: AppRadii.card,
                          child: Material(
                            color: AppColors.surfaceAlt,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accent,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user?.name.isNotEmpty == true
                                              ? user!.name
                                              : 'Tu cuenta',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          user?.email ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textMeta,
                                              ),
                                        ),
                                        if (user != null) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            'Miembro desde '
                                            '${DateFormatters.formatMonthYear(user.createdAt)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textMeta,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ajustes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const _SettingsSection(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _loggingOut ? null : _logout,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.button,
                      ),
                    ),
                    icon: _loggingOut
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          )
                        : const Icon(Icons.logout_rounded, size: 18),
                    label: Text(
                      _loggingOut ? 'Cerrando sesión...' : 'Cerrar sesión',
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SettingTile(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.accent,
          title: 'Acerca de hamy',
          subtitle: 'Versión 1.0 · tus recuerdos, siempre a mano',
        ),
        const SizedBox(height: 10),
        _SettingTile(
          icon: Icons.cloud_outlined,
          iconColor: AppColors.leaf,
          title: 'Servidor',
          subtitle: AppConfig.apiBaseUrl,
        ),
        const SizedBox(height: 10),
        const _SettingTile(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.cherry,
          title: 'Privacidad',
          subtitle: 'Solo las personas invitadas ven tus álbumes',
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: AppRadii.pill,
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMeta,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
