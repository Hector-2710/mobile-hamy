import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/paper_backdrop.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_error_banner.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth});

  final AuthController auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    widget.auth.clearError();
    if (!_formKey.currentState!.validate()) return;
    await widget.auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const PaperBackdrop(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  child: ListenableBuilder(
                    listenable: widget.auth,
                    builder: (context, _) {
                      final auth = widget.auth;
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(child: AppLogo(size: 94)),
                            const SizedBox(height: 14),
                            Text(
                              'Juntos',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'Bienvenido de vuelta',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Entra para volver a recorrer vuestros '
                              'recuerdos.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(
                                  Icons.alternate_email_rounded,
                                  size: 20,
                                ),
                              ),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) return 'Ingresa tu correo';
                                if (!v.contains('@')) return 'Correo no válido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscure,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                  tooltip: _obscure
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                            if (auth.errorMessage != null) ...[
                              const SizedBox(height: 14),
                              AuthErrorBanner(message: auth.errorMessage!),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: auth.isLoading ? null : _submit,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Iniciar sesión'),
                            ),
                            const SizedBox(height: 14),
                            const _DividerOr(),
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              onPressed: auth.isLoading
                                  ? null
                                  : () async {
                                      auth.clearError();
                                      await auth.loginWithGoogle();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textBody,
                                side: const BorderSide(
                                  color: AppColors.borderInput,
                                ),
                                minimumSize: const Size.fromHeight(48),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.button,
                                ),
                              ),
                              icon: const _GoogleGIcon(),
                              label: Text(
                                auth.isLoading
                                    ? 'Espera un momento...'
                                    : 'Continuar con Google',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(color: AppColors.textBody),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () {
                                      auth.clearError();
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              RegisterPage(auth: widget.auth),
                                        ),
                                      );
                                    },
                              child: const Text(
                                '¿Aún no tienes cuenta? Crear una',
                              ),
                            ),
                            const SizedBox(height: 18),
                            const _PrivacyNote(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleGIcon extends StatelessWidget {
  const _GoogleGIcon();

  @override
  Widget build(BuildContext context) {
    // Icono «G» de Google sin necesidad de imágenes: se dibuja en un círculo
    // blanco para que resalte sobre el fondo de la app.
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: TextStyle(
          fontFamily: AppTypography.sansFamily,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _DividerOr extends StatelessWidget {
  const _DividerOr();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borderLight)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight)),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock_outline_rounded,
          size: 13,
          color: AppColors.leafDeep,
        ),
        const SizedBox(width: 5),
        Text(
          'Un álbum privado para dos.',
          style: AppTypography.metaOnLight.copyWith(
            color: AppColors.textMeta,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}
