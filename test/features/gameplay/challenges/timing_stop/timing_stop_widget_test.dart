import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/timing_stop/timing_stop.dart';

void main() {
  const plan = RoundPlan(
    moduleId: 'timing_stop',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 7,
    difficulty: MvpDifficulty.easy,
    parameters: {'speed': 50, 'zoneSize': 20, 'directionChanges': 2},
  );

  Widget subject(Duration elapsed, ValueChanged<TimingStopAction> onAction) =>
      MaterialApp(
        home: Scaffold(
          body: TimingStopWidget(
            plan: plan,
            elapsed: elapsed,
            onAction: onAction,
          ),
        ),
      );

  testWidgets('exposes text alternatives for target, marker, and direction', (
    tester,
  ) async {
    await tester.pumpWidget(subject(Duration.zero, (_) {}));

    expect(find.textContaining('Target zone:'), findsOneWidget);
    expect(find.textContaining('Marker:'), findsOneWidget);
    expect(find.text('TARGET ZONE'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Stop marker at [0-9]+ percent$')),
      findsOneWidget,
    );
  });

  testWidgets('resolves one tap at the injected fake-clock elapsed time', (
    tester,
  ) async {
    final actions = <TimingStopAction>[];
    const elapsed = Duration(milliseconds: 750);
    await tester.pumpWidget(subject(elapsed, actions.add));

    await tester.tap(find.text('STOP'));
    await tester.tap(find.text('STOP'));

    expect(actions, hasLength(1));
    expect(actions.single.elapsed, elapsed);
  });
}
