import 'package:material_ui/material_ui.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/albums_repository.dart';
import '../state/albums_controller.dart';
import '../widgets/albums_tab.dart';
import '../widgets/invitations_tab.dart';
import '../widgets/account_tab.dart';

/// Contenedor de la app con barra inferior: Álbumes · Invitaciones · Cuenta.
class AlbumsShellPage extends StatefulWidget {
  const AlbumsShellPage({super.key});

  @override
  State<AlbumsShellPage> createState() => _AlbumsShellPageState();
}

class _AlbumsShellPageState extends State<AlbumsShellPage> {
  int _index = 0;

  late final AlbumsController _albums;
  late final InvitationsController _invitations;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final AlbumsRepository repository = AppScope.albumsOf(context);
    _albums = AlbumsController(repository)..load();
    _invitations = InvitationsController(repository)..load();
  }

  @override
  void dispose() {
    _albums.dispose();
    _invitations.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    // Refresca al entrar en Invitaciones para no mostrar invitaciones viejas.
    if (index == 1) _invitations.load();
  }

  @override
  Widget build(BuildContext context) {
    final pending = _invitations.pendingCount;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(
        index: _index,
        children: [
          AlbumsTab(
            controller: _albums,
            onJoinedAlbum: () => _albums.load(silent: true),
          ),
          InvitationsTab(
            controller: _invitations,
            onAccepted: () => _albums.load(silent: true),
          ),
          const AccountTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onDestinationSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.accentGlow,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.photo_library_outlined),
            selectedIcon: Icon(Icons.photo_library_rounded),
            label: 'Álbumes',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.mail_outline_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.mark_email_read_rounded),
            ),
            label: 'Invitaciones',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}
