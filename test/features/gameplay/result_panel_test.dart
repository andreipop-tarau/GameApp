import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/result_panel.dart';

void main() {
  testWidgets('shows the latest XP delta', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPanel(
          evaluation: const RoundEvaluation(
            outcome: ChallengeOutcome.success,
            metrics: RoundMetrics(responseTime: Duration.zero, actionCount: 1),
          ),
          xpDelta: 20,
          onAgain: () {},
          onHome: () {},
        ),
      ),
    );

    expect(find.text('+20 XP'), findsOneWidget);
  });
}
