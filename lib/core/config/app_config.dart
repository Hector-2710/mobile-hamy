import 'package:flutter/foundation.dart';

/// Configuración base de la app.
abstract final class AppConfig {
  static const String appName = 'Juntos';

  static const String _localhost = 'http://localhost:8080';
  static const String _androidEmulatorHost = 'http://10.0.2.2:8080';

  /// Sobrescribir con: --dart-define=API_BASE_URL=http://host:8080
  /// Necesario en dispositivo físico (IP de la LAN) o entornos personalizados.
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Base URL de la API (api-hamy).
  ///
  /// En el emulador Android, `localhost` apunta al propio emulador; la IP del
  /// equipo que ejecuta Flutter es `10.0.2.2`. En web/desktop sí se usa
  /// `localhost` porque la app corre en la misma máquina que el Docker.
  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return _androidEmulatorHost;
    }
    return _localhost;
  }
}
