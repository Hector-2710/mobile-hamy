import 'package:material_ui/material_ui.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/auth_gate.dart';
import '../features/auth/presentation/state/auth_controller.dart';

class HamyApp extends StatelessWidget {
  const HamyApp({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      themeAnimationDuration: const Duration(milliseconds: 220),
      home: AuthGate(auth: auth),
    );
  }
}
