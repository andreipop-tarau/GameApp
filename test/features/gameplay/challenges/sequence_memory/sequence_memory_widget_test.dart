import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/sequence_memory/sequence_memory.dart';

void main() {
  final plan = RoundPlan(
    moduleId: 'sequence_memory',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 7,
    difficulty: MvpDifficulty.easy,
    parameters: const {
      'sequenceLength': 2,
      'displayMs': 1000,
      'symbolCount': 3,
      'timeoutMs': 3000,
    },
  );

  Widget subject(
    Duration elapsed,
    ValueChanged<SequenceMemoryAction> onAction,
  ) => MaterialApp(
    home: Scaffold(
      body: SequenceMemoryWidget(
        plan: plan,
        elapsed: elapsed,
        onAction: onAction,
      ),
    ),
  );

  testWidgets('presentation phase disables symbol input', (tester) async {
    final actions = <SequenceMemoryAction>[];
    await tester.pumpWidget(
      subject(const Duration(milliseconds: 500), actions.add),
    );

    expect(find.textContaining('Remember this symbol:'), findsOneWidget);
    expect(
      find.text('Input is disabled while the sequence is shown.'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Symbol 1: STAR'), findsNothing);
  });

  testWidgets('input phase exposes labeled symbols and resolves once', (
    tester,
  ) async {
    final actions = <SequenceMemoryAction>[];
    await tester.pumpWidget(subject(const Duration(seconds: 2), actions.add));

    expect(find.bySemanticsLabel('Symbol 1: STAR'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Symbol 1: STAR'));
    await tester.tap(find.bySemanticsLabel('Symbol 1: STAR'));

    expect(actions, hasLength(1));
  });

  testWidgets('timeout emits one action', (tester) async {
    final actions = <SequenceMemoryAction>[];
    await tester.pumpWidget(subject(const Duration(seconds: 5), actions.add));
    await tester.pump();

    expect(find.text('Time is up'), findsOneWidget);
    expect(actions.map((action) => action.kind), [
      SequenceMemoryActionKind.timeout,
    ]);
  });
}
