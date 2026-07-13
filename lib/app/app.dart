import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'router.dart';

class MindTrapApp extends StatelessWidget {
  const MindTrapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MindTrap AI',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
