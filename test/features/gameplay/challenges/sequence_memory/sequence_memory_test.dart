import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/sequence_memory/sequence_memory.dart';

void main() {
  const generator = SequenceMemoryPlanGenerator();
  const config = MvpModuleConfig(
    id: MvpModuleId.sequenceMemory,
    enabled: true,
    difficultyBands: {
      MvpDifficulty.easy: {
        'sequenceLength': 3,
        'displayMs': 1000,
        'symbolCount': 3,
        'timeoutMs': 8000,
      },
      MvpDifficulty.medium: {
        'sequenceLength': 6,
        'displayMs': 650,
        'symbolCount': 5,
        'timeoutMs': 12000,
      },
      MvpDifficulty.hard: {
        'sequenceLength': 9,
        'displayMs': 350,
        'symbolCount': 7,
        'timeoutMs': 16000,
      },
    },
  );
  final epoch = DateTime.utc(2000);

  RoundPlan plan() => generator.generate(
    config: config,
    difficulty: MvpDifficulty.easy,
    seed: 42,
    configVersion: '1.0.0',
  );

  test('seeded generation produces the same valid sequence', () {
    final first = plan();
    final second = plan();

    expect(generator.sequenceFor(first), generator.sequenceFor(second));
    expect(const SequenceMemoryValidator().isValid(first), isTrue);
  });

  test('validator rejects out-of-bounds sequence parameters', () {
    final invalid = RoundPlan(
      moduleId: 'sequence_memory',
      moduleVersion: '1',
      configVersion: '1.0.0',
      seed: 1,
      difficulty: MvpDifficulty.easy,
      parameters: const {
        'sequenceLength': 1,
        'displayMs': 1000,
        'symbolCount': 3,
        'timeoutMs': 8000,
      },
    );

    expect(const SequenceMemoryValidator().isValid(invalid), isFalse);
  });

  test('evaluation handles correct, wrong, and timeout outcomes', () {
    const evaluator = SequenceMemoryEvaluator();
    final round = plan();
    final expected = generator.sequenceFor(round);

    RoundEvaluation evaluate(SequenceMemoryAction action, int elapsedMs) =>
        evaluator.evaluate(
          plan: round,
          action: action,
          currentRoundTime: epoch.add(Duration(milliseconds: elapsedMs)),
        );

    expect(
      evaluate(
        SequenceMemoryAction.input(
          symbols: expected,
          elapsed: const Duration(seconds: 4),
        ),
        4000,
      ).outcome,
      ChallengeOutcome.success,
    );
    expect(
      evaluate(
        SequenceMemoryAction.input(
          symbols: [0],
          elapsed: const Duration(seconds: 4),
        ),
        4000,
      ).outcome,
      ChallengeOutcome.failure,
    );
    expect(
      evaluate(
        SequenceMemoryAction.timeout(elapsed: const Duration(seconds: 11)),
        11000,
      ).outcome,
      ChallengeOutcome.failure,
    );
  });
}
