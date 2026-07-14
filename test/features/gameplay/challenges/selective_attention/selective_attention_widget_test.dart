import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/selective_attention/selective_attention.dart';

void main() {
  final plan = RoundPlan(
    moduleId: 'selective_attention',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 7,
    difficulty: MvpDifficulty.easy,
    parameters: const {
      'itemCount': 4,
      'similarity': 20,
      'motionSpeed': 0,
      'timeoutMs': 2000,
    },
  );

  Widget subject(
    Duration elapsed,
    ValueChanged<SelectiveAttentionAction> onAction,
  ) => MaterialApp(
    home: Scaffold(
      body: SelectiveAttentionWidget(
        plan: plan,
        elapsed: elapsed,
        onAction: onAction,
      ),
    ),
  );

  testWidgets('shows a text target rule and resolves one item tap', (
    tester,
  ) async {
    final actions = <SelectiveAttentionAction>[];
    final layout = const SelectiveAttentionPlanGenerator().layoutFor(plan);
    await tester.pumpWidget(subject(const Duration(seconds: 1), actions.add));

    expect(find.text('Tap the ${layout.targetSymbol}'), findsOneWidget);
    await tester.tap(
      find.bySemanticsLabel(
        'Attention item ${layout.target.id + 1}: ${layout.target.symbol}',
      ),
    );
    await tester.tap(
      find.bySemanticsLabel(
        'Attention item ${layout.target.id + 1}: ${layout.target.symbol}',
      ),
    );

    expect(actions, hasLength(1));
    expect(actions.single.itemId, layout.target.id);
  });

  testWidgets('timeout resolves once', (tester) async {
    final actions = <SelectiveAttentionAction>[];
    await tester.pumpWidget(subject(const Duration(seconds: 2), actions.add));
    await tester.pump();

    expect(find.text('Time is up'), findsOneWidget);
    expect(actions.map((action) => action.kind), [
      SelectiveAttentionActionKind.timeout,
    ]);
  });
}
