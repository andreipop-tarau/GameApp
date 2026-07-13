import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('MindTrap AI')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('MindTrap AI', style: textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.large),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed('play'),
                      child: const Text('Play'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => context.pushNamed('profile'),
                      child: const Text('Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
