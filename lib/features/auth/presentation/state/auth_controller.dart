import 'package:material_ui/material_ui.dart';

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
