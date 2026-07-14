import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/reaction_tap/reaction_tap.dart';

void main() {
  final plan = RoundPlan(
    moduleId: 'reaction_tap',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 7,
    difficulty: MvpDifficulty.easy,
    parameters: const {
      'cueDelayMs': 1000,
      'targetSizePx': 64,
      'distractorCount': 2,
      'timeoutMs': 2000,
    },
  );

  Widget subject(Duration elapsed, ValueChanged<ReactionTapAction> onAction) =>
      MaterialApp(
        home: Scaffold(
          body: ReactionTapWidget(
            plan: plan,
            elapsed: elapsed,
            onAction: onAction,
          ),
        ),
      );

  testWidgets('shows a text cue and resolves an early tap once', (
    tester,
  ) async {
    final actions = <ReactionTapAction>[];
    await tester.pumpWidget(
      subject(const Duration(milliseconds: 500), actions.add),
    );

    expect(find.text('WAIT'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        'Wait for the GO cue. Tapping now loses the round.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('WAIT'));
    await tester.tap(find.text('WAIT'));

    expect(actions, hasLength(1));
    expect(actions.single.kind, ReactionTapActionKind.target);
  });

  testWidgets('shows labeled target and distractors after the cue', (
    tester,
  ) async {
    final actions = <ReactionTapAction>[];
    await tester.pumpWidget(
      subject(const Duration(milliseconds: 1000), actions.add),
    );

    expect(find.text('GO — tap the GO target'), findsOneWidget);
    expect(find.bySemanticsLabel('GO target'), findsOneWidget);
    expect(find.bySemanticsLabel('WAIT distractor'), findsNWidgets(2));
    await tester.tap(find.bySemanticsLabel('GO target'));

    expect(actions.single.kind, ReactionTapActionKind.target);
  });

  testWidgets('emits one timeout action when injected elapsed time expires', (
    tester,
  ) async {
    final actions = <ReactionTapAction>[];
    await tester.pumpWidget(
      subject(const Duration(milliseconds: 3000), actions.add),
    );
    await tester.pump();

    expect(find.text('Time is up'), findsOneWidget);
    expect(actions.map((action) => action.kind), [
      ReactionTapActionKind.timeout,
    ]);
  });
}
