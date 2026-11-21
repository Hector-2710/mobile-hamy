import 'package:flutter/foundation.dart';

/// Configuración base de la app.
abstract final class AppConfig {
  static const String appName = 'hamy';

  static const String _localhost = 'http://localhost:8080';
  static const String _androidEmulatorHost = 'http://10.0.2.2:8080';

  /// Sobrescribir con: --dart-define=API_BASE_URL=http://host:8080
  /// Necesario en dispositivo físico (IP de la LAN) o entornos personalizados.
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Web Client ID de Google OAuth.
  ///
  /// Es el mismo que la API valida como audience de los ID tokens. En iOS
  /// funciona como `serverClientId` (el ID token lo pide contra este) y en
  /// Android igual; el Client ID de iOS y el de Android no se pasan en el
  /// código (Android se deriva del paquete + SHA-1 y iOS va en Info.plist).
  ///
  /// Sobrescribir con: --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue:
        '730984096128-osm3eklko71mmhlrhhgc2jud1q56osfs.apps.googleusercontent.com',
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
