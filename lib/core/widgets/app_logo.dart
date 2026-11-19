import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

/// Logotipo de Juntos en un medallón de papel, con un aro de fresa suave.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final cacheSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Semantics(
      label: 'Juntos',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.055),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
          border: Border.all(color: AppColors.surface, width: size * 0.02),
          boxShadow: showShadow ? AppShadows.logo : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.accentGlow,
              width: size * 0.014,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'lib/logo.jpeg',
            fit: BoxFit.cover,
            cacheWidth: cacheSize,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: AppColors.blush,
                child: Center(
                  child: Icon(
                    Icons.favorite_rounded,
                    color: AppColors.accent,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
