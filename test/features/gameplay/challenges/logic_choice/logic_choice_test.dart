import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/logic_choice/logic_choice.dart';

void main() {
  RoundPlan plan({
    int seed = 1,
    int complexity = 3,
    int choiceCount = 4,
    int timeoutMs = 3000,
  }) => RoundPlan(
    moduleId: 'logic_choice',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: seed,
    difficulty: MvpDifficulty.medium,
    parameters: {
      'ruleComplexity': complexity,
      'choiceCount': choiceCount,
      'timeoutMs': timeoutMs,
    },
  );

  test(
    'templates produce one correct answer and distinct distractors at bounds',
    () {
      const generator = LogicChoicePlanGenerator();
      for (var complexity = 1; complexity <= 5; complexity++) {
        for (var choiceCount = 2; choiceCount <= 6; choiceCount++) {
          for (var seed = 0; seed < 30; seed++) {
            final puzzle = generator.puzzleFor(
              plan(
                seed: seed,
                complexity: complexity,
                choiceCount: choiceCount,
              ),
            );
            expect(puzzle.choices, hasLength(choiceCount));
            expect(puzzle.choices.toSet(), hasLength(choiceCount));
            expect(
              puzzle.choices.where((choice) => choice == puzzle.correctAnswer),
              hasLength(1),
            );
          }
        }
      }
    },
  );

  test('seeded puzzle and answer ordering are stable', () {
    const generator = LogicChoicePlanGenerator();
    final first = generator.puzzleFor(plan(seed: 99));
    final second = generator.puzzleFor(plan(seed: 99));

    expect(second.template, first.template);
    expect(second.prompt, first.prompt);
    expect(second.choices, first.choices);
  });

  test('validator rejects out-of-bounds template parameters', () {
    for (final invalid in [
      plan(complexity: 0),
      plan(choiceCount: 7),
      plan(timeoutMs: 999),
    ]) {
      expect(const LogicChoiceValidator().isValid(invalid), isFalse);
    }
  });

  test('evaluation resolves correct, wrong, and timeout outcomes', () {
    const generator = LogicChoicePlanGenerator();
    const evaluator = LogicChoiceEvaluator();
    final round = plan(seed: 19);
    final puzzle = generator.puzzleFor(round);
    final epoch = DateTime.utc(2000);
    final correct = evaluator.evaluate(
      plan: round,
      action: LogicChoiceAction.select(
        choiceIndex: puzzle.correctChoiceIndex,
        elapsed: const Duration(milliseconds: 500),
      ),
      currentRoundTime: epoch.add(const Duration(milliseconds: 500)),
    );
    final wrong = evaluator.evaluate(
      plan: round,
      action: LogicChoiceAction.select(
        choiceIndex: (puzzle.correctChoiceIndex + 1) % puzzle.choices.length,
        elapsed: const Duration(milliseconds: 500),
      ),
      currentRoundTime: epoch.add(const Duration(milliseconds: 500)),
    );
    final timedOut = evaluator.evaluate(
      plan: round,
      action: LogicChoiceAction.timeout(elapsed: const Duration(seconds: 3)),
      currentRoundTime: epoch.add(const Duration(seconds: 3)),
    );

    expect(correct.outcome, ChallengeOutcome.success);
    expect(wrong.outcome, ChallengeOutcome.failure);
    expect(timedOut.outcome, ChallengeOutcome.failure);
  });
}
