import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Lavado de acuarela de fresa y hoja que acompaña las pantallas de acceso.
class PaperBackdrop extends StatelessWidget {
  const PaperBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              right: -120,
              top: -150,
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.blush.withValues(alpha: 0.9),
                      AppColors.blush.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -140,
              bottom: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.leafSoft.withValues(alpha: 0.7),
                      AppColors.leafSoft.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
