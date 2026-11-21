import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/paper_backdrop.dart';
import '../../../albums/presentation/pages/albums_shell_page.dart';
import '../state/auth_controller.dart';
import 'login_page.dart';

/// Puerta de acceso: muestra la carga con el logotipo durante un segundo
/// mínimo y luego hace una transición de fundido al inicio de sesión o al
/// álbum, según el resultado del arranque.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth});

  final AuthController auth;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const Duration _minSplash = Duration(seconds: 1);

  late final DateTime _splashStart = DateTime.now();
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    widget.auth.addListener(_onAuthChanged);
    // Aunque el arranque termine antes, la carga se sostiene el tiempo mínimo.
    _splashTimer = Timer(_minSplash, () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    widget.auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  bool get _splashElapsed =>
      DateTime.now().difference(_splashStart) >= _minSplash;

  @override
  Widget build(BuildContext context) {
    final status = widget.auth.status;

    final Widget target;
    if (!_splashElapsed || status == AuthStatus.unknown) {
      target = const _SplashScreen();
    } else if (status == AuthStatus.unauthenticated) {
      target = LoginPage(auth: widget.auth);
    } else {
      target = const AlbumsShellPage();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: target,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const PaperBackdrop(),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppLogo(size: 96),
                  const SizedBox(height: 18),
                  Text(
                    'hamy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
