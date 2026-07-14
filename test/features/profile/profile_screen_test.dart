import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_provider.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_updater.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/profile/profile_screen.dart';

void main() {
  testWidgets('shows five accessible skills and an honest sparse-data state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ProfileScreen())),
    );

    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(find.bySemanticsLabel('Reaction skill'), findsOneWidget);
    for (final label in const [
      'Reaction',
      'Memory',
      'Attention',
      'Logic',
      'Timing',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text(label), findsOneWidget);
      expect(find.text('No estimate yet'), findsWidgets);
      expect(find.text('Confidence: 0%'), findsWidgets);
      expect(find.text('Samples: 0'), findsWidgets);
    }
    semantics.dispose();
  });

  testWidgets('renders an updated skill with confidence and sample count', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container
        .read(brainProfileProvider.notifier)
        .applyOutcome(
          const BrainProfileOutcome(
            id: 'reaction-1',
            category: ChallengeCategory.reaction,
            performance: 100,
            status: BrainProfileOutcomeStatus.completed,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('58 / 100'), findsOneWidget);
    expect(find.text('Confidence: 10%'), findsOneWidget);
    expect(find.text('Samples: 1'), findsOneWidget);
    expect(find.text('Not enough data yet'), findsOneWidget);
  });
}
