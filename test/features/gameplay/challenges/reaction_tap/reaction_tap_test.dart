import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/reaction_tap/reaction_tap.dart';

void main() {
  const generator = ReactionTapPlanGenerator();
  const config = MvpModuleConfig(
    id: MvpModuleId.reactionTap,
    enabled: true,
    difficultyBands: {
      MvpDifficulty.easy: {
        'cueDelayMs': 1200,
        'targetSizePx': 112,
        'distractorCount': 0,
        'timeoutMs': 5000,
      },
      MvpDifficulty.medium: {
        'cueDelayMs': 800,
        'targetSizePx': 72,
        'distractorCount': 3,
        'timeoutMs': 3500,
      },
      MvpDifficulty.hard: {
        'cueDelayMs': 500,
        'targetSizePx': 48,
        'distractorCount': 6,
        'timeoutMs': 2200,
      },
    },
  );
  final epoch = DateTime.utc(2000);

  RoundPlan plan() => generator.generate(
    config: config,
    difficulty: MvpDifficulty.medium,
    seed: 123,
    configVersion: '1.0.0',
  );

  test('seeded generation is stable and produces a valid bounded plan', () {
    final first = plan();
    final second = plan();

    expect(second.parameters, first.parameters);
    expect(second.seed, first.seed);
    expect(const ReactionTapValidator().isValid(first), isTrue);
  });

  test('evaluation handles early, correct, wrong, and timeout actions', () {
    const evaluator = ReactionTapEvaluator();
    final round = plan();

    RoundEvaluation evaluate(ReactionTapActionKind kind, int elapsedMs) =>
        evaluator.evaluate(
          plan: round,
          action: ReactionTapAction(
            kind: kind,
            elapsed: Duration(milliseconds: elapsedMs),
          ),
          currentRoundTime: epoch.add(Duration(milliseconds: elapsedMs)),
        );

    expect(
      evaluate(ReactionTapActionKind.target, 400).outcome,
      ChallengeOutcome.failure,
    );
    expect(
      evaluate(ReactionTapActionKind.target, 1000).outcome,
      ChallengeOutcome.success,
    );
    expect(
      evaluate(ReactionTapActionKind.distractor, 1000).outcome,
      ChallengeOutcome.failure,
    );
    expect(
      evaluate(ReactionTapActionKind.timeout, 4300).outcome,
      ChallengeOutcome.failure,
    );
  });
}
