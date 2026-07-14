import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'router.dart';

class MindTrapApp extends StatelessWidget {
  const MindTrapApp({super.key, this.container});

  final ProviderContainer? container;

  @override
  Widget build(BuildContext context) {
    final app = MaterialApp.router(
      title: 'MindTrap AI',
      theme: appTheme,
      routerConfig: appRouter,
    );
    final rootContainer = container;
    if (rootContainer == null) return app;
    return UncontrolledProviderScope(container: rootContainer, child: app);
  }
}
