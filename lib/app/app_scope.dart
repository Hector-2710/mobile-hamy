import 'package:material_ui/material_ui.dart';

import '../features/albums/data/repositories/albums_repository.dart';
import '../features/auth/presentation/state/auth_controller.dart';

class AppScope extends InheritedNotifier<AuthController> {
  const AppScope({
    super.key,
    required AuthController controller,
    required this.albums,
    required super.child,
  }) : super(notifier: controller);

  final AlbumsRepository albums;

  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.notifier!;
  }

  static AuthController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppScope>()?.notifier;
  }

  /// Repositorio de álbumes disponible en cualquier parte de la app.
  static AlbumsRepository albumsOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in context');
    return scope!.albums;
  }
}
