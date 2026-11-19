import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/network/api_client.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/state/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenProvider: tokenStorage.readToken);
  final authRepository = AuthRepository(
    remote: AuthRemoteDatasource(apiClient),
    tokenStorage: tokenStorage,
  );
  final authController = AuthController(authRepository);
  apiClient.onUnauthorized = authController.logout;

  await authController.bootstrap();

  runApp(
    AppScope(
      controller: authController,
      child: HamyApp(auth: authController),
    ),
  );
}
