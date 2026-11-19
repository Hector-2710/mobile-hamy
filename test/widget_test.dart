import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_hamy/core/config/app_config.dart';

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('usa el host del emulador Android por defecto', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(AppConfig.apiBaseUrl, 'http://10.0.2.2:8080');
  });

  test('usa localhost en el resto de plataformas', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    expect(AppConfig.apiBaseUrl, 'http://localhost:8080');
  });
}
