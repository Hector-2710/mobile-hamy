import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  AuthStatus status = AuthStatus.unknown;
  UserModel? user;
  String? errorMessage;
  bool isLoading = false;

  // GoogleSignIn.initialize solo puede llamarse una vez por instancia.
  bool _googleInitialized = false;

  Future<void> bootstrap() async {
    try {
      final hasToken = await _repository.hasToken();
      if (!hasToken) {
        status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }
      user = await _repository.me();
      status = AuthStatus.authenticated;
    } catch (_) {
      await _repository.logout();
      user = null;
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await _repository.login(email: email, password: password);
      user = session.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo iniciar sesión.';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Inicia sesión con Google: pide el ID token al plugin y lo canjea por una
  /// sesión normal de la API. Si el usuario cancela el selector de cuentas no
  /// se muestra ningún error.
  Future<bool> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final signIn = GoogleSignIn.instance;
      if (!_googleInitialized) {
        await signIn.initialize(
          serverClientId: AppConfig.googleWebClientId,
        );
        _googleInitialized = true;
      }

      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        errorMessage =
            'No se pudo obtener el token de Google. Inténtalo de nuevo.';
        isLoading = false;
        notifyListeners();
        return false;
      }

      final session = await _repository.loginWithGoogle(idToken: idToken);
      user = session.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // El usuario canceló el selector de cuentas: no es un error.
        isLoading = false;
        notifyListeners();
        return false;
      }
      errorMessage = _googleSignInError(e);
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage =
          'No se pudo iniciar sesión con Google. Revisa tu conexión e '
          'inténtalo de nuevo.';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final session = await _repository.register(
        name: name,
        email: email,
        password: password,
      );
      user = session.user;
      status = AuthStatus.authenticated;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No se pudo crear la cuenta.';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  /// Traduce un error de google_sign_in a un mensaje claro en español.
  static String _googleSignInError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Sign-In no está configurado en esta app. Contacta con '
            'soporte.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Se interrumpió el inicio de sesión con Google. Inténtalo de '
            'nuevo.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'No se pudo mostrar el selector de cuentas de Google. Cierra '
            'la app e inténtalo de nuevo.';
      case GoogleSignInExceptionCode.userMismatch:
        return 'Esa cuenta no coincide con la sesión anterior. Cierra sesión '
            'e inténtalo de nuevo.';
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.unknownError:
        return 'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';
    }
  }


  Future<void> logout() async {
    await _repository.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
