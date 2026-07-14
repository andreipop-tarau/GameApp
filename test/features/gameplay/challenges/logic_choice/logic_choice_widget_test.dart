import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/logic_choice/logic_choice.dart';

void main() {
  const plan = RoundPlan(
    moduleId: 'logic_choice',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 7,
    difficulty: MvpDifficulty.easy,
    parameters: {'ruleComplexity': 3, 'choiceCount': 4, 'timeoutMs': 2000},
  );

  Widget subject(Duration elapsed, ValueChanged<LogicChoiceAction> onAction) =>
      MaterialApp(
        home: Scaffold(
          body: LogicChoiceWidget(
            plan: plan,
            elapsed: elapsed,
            onAction: onAction,
          ),
        ),
      );

  testWidgets('uses clear prompt and accessible choice labels', (tester) async {
    await tester.pumpWidget(subject(Duration.zero, (_) {}));

    expect(find.textContaining('number'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Choice 1: [0-9]+$')),
      findsOneWidget,
    );
  });

  testWidgets('resolves a selected choice once', (tester) async {
    final actions = <LogicChoiceAction>[];
    await tester.pumpWidget(subject(Duration.zero, actions.add));

    await tester.tap(find.bySemanticsLabel(RegExp(r'^Choice 1: [0-9]+$')));
    await tester.tap(find.bySemanticsLabel(RegExp(r'^Choice 1: [0-9]+$')));

    expect(actions, hasLength(1));
    expect(actions.single.kind, LogicChoiceActionKind.select);
  });

  testWidgets('emits one timeout action', (tester) async {
    final actions = <LogicChoiceAction>[];
    await tester.pumpWidget(
      subject(const Duration(milliseconds: 2000), actions.add),
    );
    await tester.pump();

    expect(find.text('Time is up'), findsOneWidget);
    expect(actions.map((action) => action.kind), [
      LogicChoiceActionKind.timeout,
    ]);
  });
}
