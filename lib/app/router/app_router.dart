import 'package:material_ui/material_ui.dart';

import '../../features/memories/presentation/pages/memories_home_page.dart';

abstract final class AppRouter {
  static const String home = '/';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const MemoriesHomePage(),
  };
}
