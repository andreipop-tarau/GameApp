import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/selective_attention/selective_attention.dart';

void main() {
  const generator = SelectiveAttentionPlanGenerator();
  const config = MvpModuleConfig(
    id: MvpModuleId.selectiveAttention,
    enabled: true,
    difficultyBands: {
      MvpDifficulty.easy: {
        'itemCount': 4,
        'similarity': 20,
        'motionSpeed': 0,
        'timeoutMs': 7000,
      },
      MvpDifficulty.medium: {
        'itemCount': 9,
        'similarity': 55,
        'motionSpeed': 35,
        'timeoutMs': 5500,
      },
      MvpDifficulty.hard: {
        'itemCount': 15,
        'similarity': 85,
        'motionSpeed': 70,
        'timeoutMs': 4000,
      },
    },
  );
  final epoch = DateTime.utc(2000);

  RoundPlan plan(int seed) => generator.generate(
    config: config,
    difficulty: MvpDifficulty.medium,
    seed: seed,
    configVersion: '1.0.0',
  );

  test('seeded plans generate deterministic valid layouts', () {
    final first = plan(42);
    final second = plan(42);

    expect(
      generator.layoutFor(first).targetSymbol,
      generator.layoutFor(second).targetSymbol,
    );
    expect(
      generator.layoutFor(first).items.map((item) => item.slot),
      generator.layoutFor(second).items.map((item) => item.slot),
    );
    expect(const SelectiveAttentionValidator().isValid(first), isTrue);
  });

  test('evaluation handles correct, wrong, and timeout actions', () {
    const evaluator = SelectiveAttentionEvaluator();
    final round = plan(42);
    final target = generator.layoutFor(round).target;

    RoundEvaluation evaluate(SelectiveAttentionAction action, int elapsedMs) =>
        evaluator.evaluate(
          plan: round,
          action: action,
          currentRoundTime: epoch.add(Duration(milliseconds: elapsedMs)),
        );

    expect(
      evaluate(
        SelectiveAttentionAction.select(
          itemId: target.id,
          elapsed: const Duration(seconds: 1),
        ),
        1000,
      ).outcome,
      ChallengeOutcome.success,
    );
    expect(
      evaluate(
        SelectiveAttentionAction.select(
          itemId: -1,
          elapsed: const Duration(seconds: 1),
        ),
        1000,
      ).outcome,
      ChallengeOutcome.failure,
    );
    expect(
      evaluate(
        SelectiveAttentionAction.timeout(elapsed: const Duration(seconds: 6)),
        6000,
      ).outcome,
      ChallengeOutcome.failure,
    );
  });
}
