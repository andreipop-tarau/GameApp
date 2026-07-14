import 'package:flutter/material.dart';

import '../../../../core/mvp_config.dart';
import '../../../../core/seeded_random.dart';
import '../../challenge.dart';

const _moduleId = 'logic_choice';
const _moduleVersion = '1';
final DateTime _roundEpoch = DateTime.utc(2000);

enum LogicChoiceTemplate { additiveSequence, multiplicationSequence, outlier }

final class LogicChoicePuzzle {
  const LogicChoicePuzzle({
    required this.template,
    required this.prompt,
    required this.correctAnswer,
    required this.choices,
  });

  final LogicChoiceTemplate template;
  final String prompt;
  final int correctAnswer;
  final List<int> choices;

  int get correctChoiceIndex => choices.indexOf(correctAnswer);
}

final class LogicChoicePlanGenerator {
  const LogicChoicePlanGenerator();

  RoundPlan generate({
    required MvpModuleConfig config,
    required MvpDifficulty difficulty,
    required int seed,
    required String configVersion,
  }) {
    if (config.id != MvpModuleId.logicChoice || !config.enabled) {
      throw ArgumentError.value(
        config,
        'config',
        'Logic Choice must be enabled.',
      );
    }
    final parameters = config.difficultyBands[difficulty];
    if (parameters == null) {
      throw ArgumentError.value(
        difficulty,
        'difficulty',
        'Difficulty is not configured.',
      );
    }
    final plan = RoundPlan(
      moduleId: _moduleId,
      moduleVersion: _moduleVersion,
      configVersion: configVersion,
      seed: seed,
      difficulty: difficulty,
      parameters: Map.unmodifiable(parameters),
    );
    if (!const LogicChoiceValidator().isValid(plan)) {
      throw StateError('Generated Logic Choice plan is invalid.');
    }
    return plan;
  }

  LogicChoicePuzzle puzzleFor(RoundPlan plan) {
    final complexity = plan.parameters['ruleComplexity'];
    final choiceCount = plan.parameters['choiceCount'];
    if (complexity == null || complexity < 1 || complexity > 5) {
      throw ArgumentError.value(plan, 'plan', 'Rule complexity is invalid.');
    }
    if (choiceCount == null || choiceCount < 2 || choiceCount > 6) {
      throw ArgumentError.value(plan, 'plan', 'Choice count is invalid.');
    }
    final random = SeededRandom(plan.seed);
    final templates = LogicChoiceTemplate.values.take(
      complexity.clamp(1, 3).toInt(),
    );
    final template = templates.elementAt(random.nextInt(templates.length));
    final puzzle = switch (template) {
      LogicChoiceTemplate.additiveSequence => _additive(random, complexity),
      LogicChoiceTemplate.multiplicationSequence => _multiplication(
        random,
        complexity,
      ),
      LogicChoiceTemplate.outlier => _outlier(random, complexity),
    };
    final choices = _orderedChoices(
      random: random,
      correctAnswer: puzzle.correctAnswer,
      distractors: puzzle.distractors,
      choiceCount: choiceCount,
    );
    return LogicChoicePuzzle(
      template: template,
      prompt: puzzle.prompt,
      correctAnswer: puzzle.correctAnswer,
      choices: List.unmodifiable(choices),
    );
  }

  _PuzzleValues _additive(SeededRandom random, int complexity) {
    final start = 2 + random.nextInt(8 + complexity * 2);
    final step = 1 + random.nextInt(complexity + 2);
    final correct = start + step * 3;
    return _PuzzleValues(
      prompt:
          'What number completes the pattern? $start, ${start + step}, ${start + step * 2}, ?',
      correctAnswer: correct,
      distractors: [
        correct - step,
        correct + step,
        correct - step * 2,
        correct + step * 2,
        start,
      ],
    );
  }

  _PuzzleValues _multiplication(SeededRandom random, int complexity) {
    final start = 1 + random.nextInt(3 + complexity);
    final multiplier = random.nextBool() ? 2 : 3;
    final second = start * multiplier;
    final third = second * multiplier;
    final correct = third * multiplier;
    return _PuzzleValues(
      prompt: 'What number completes the pattern? $start, $second, $third, ?',
      correctAnswer: correct,
      distractors: [
        correct - multiplier * 2,
        correct - multiplier,
        correct + multiplier,
        correct + multiplier * 2,
        second,
      ],
    );
  }

  _PuzzleValues _outlier(SeededRandom random, int complexity) {
    final factor = 2 + random.nextInt(complexity + 2);
    final base = 2 + random.nextInt(6 + complexity);
    final correct = base * factor + 1;
    return _PuzzleValues(
      prompt: 'Which number is not a multiple of $factor?',
      correctAnswer: correct,
      distractors: [
        base * factor,
        (base + 1) * factor,
        (base + 2) * factor,
        (base + 3) * factor,
        (base + 4) * factor,
      ],
    );
  }

  List<int> _orderedChoices({
    required SeededRandom random,
    required int correctAnswer,
    required List<int> distractors,
    required int choiceCount,
  }) {
    final distinctDistractors = <int>{};
    for (final distractor in distractors) {
      if (distractor != correctAnswer) distinctDistractors.add(distractor);
      if (distinctDistractors.length == choiceCount - 1) break;
    }
    if (distinctDistractors.length != choiceCount - 1) {
      throw StateError('Logic Choice requires distinct distractors.');
    }
    final choices = [correctAnswer, ...distinctDistractors];
    for (var index = choices.length - 1; index > 0; index--) {
      final swapIndex = random.nextInt(index + 1);
      final value = choices[index];
      choices[index] = choices[swapIndex];
      choices[swapIndex] = value;
    }
    return choices;
  }
}

final class _PuzzleValues {
  const _PuzzleValues({
    required this.prompt,
    required this.correctAnswer,
    required this.distractors,
  });

  final String prompt;
  final int correctAnswer;
  final List<int> distractors;
}

enum LogicChoiceActionKind { select, timeout }

final class LogicChoiceAction extends PlayerAction {
  LogicChoiceAction.select({required this.choiceIndex, required this.elapsed})
    : kind = LogicChoiceActionKind.select,
      super(_roundEpoch.add(elapsed));

  LogicChoiceAction.timeout({required this.elapsed})
    : kind = LogicChoiceActionKind.timeout,
      choiceIndex = null,
      super(_roundEpoch.add(elapsed));

  final LogicChoiceActionKind kind;
  final int? choiceIndex;
  final Duration elapsed;
}

final class LogicChoiceValidator implements ChallengeValidator {
  const LogicChoiceValidator();

  @override
  bool isValid(RoundPlan plan) {
    if (plan.moduleId != _moduleId || plan.moduleVersion != _moduleVersion) {
      return false;
    }
    const bounds = {
      'ruleComplexity': ChallengeParameterBounds(minimum: 1, maximum: 5),
      'choiceCount': ChallengeParameterBounds(minimum: 2, maximum: 6),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    };
    if (plan.parameters.length != bounds.length ||
        !bounds.entries.every((entry) {
          final value = plan.parameters[entry.key];
          return value != null &&
              value >= entry.value.minimum &&
              value <= entry.value.maximum;
        })) {
      return false;
    }
    final puzzle = const LogicChoicePlanGenerator().puzzleFor(plan);
    return puzzle.choices.length == plan.parameters['choiceCount'] &&
        puzzle.choices.toSet().length == puzzle.choices.length &&
        puzzle.choices
                .where((choice) => choice == puzzle.correctAnswer)
                .length ==
            1;
  }
}

final class LogicChoiceEvaluator implements ChallengeEvaluator {
  const LogicChoiceEvaluator();

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    if (action is! LogicChoiceAction) {
      throw ArgumentError.value(
        action,
        'action',
        'Logic Choice requires its action type.',
      );
    }
    final elapsed = currentRoundTime.difference(_roundEpoch);
    final timeout = Duration(milliseconds: plan.parameters['timeoutMs']!);
    final puzzle = const LogicChoicePlanGenerator().puzzleFor(plan);
    final success =
        action.kind == LogicChoiceActionKind.select &&
        elapsed < timeout &&
        action.choiceIndex == puzzle.correctChoiceIndex;
    return RoundEvaluation(
      outcome: success ? ChallengeOutcome.success : ChallengeOutcome.failure,
      metrics: RoundMetrics(responseTime: elapsed, actionCount: 1),
    );
  }
}

final class LogicChoiceModule {
  const LogicChoiceModule();

  static const metadata = ChallengeMetadata(
    id: _moduleId,
    version: _moduleVersion,
    category: ChallengeCategory.logic,
    minimumDifficulty: MvpDifficulty.easy,
    maximumDifficulty: MvpDifficulty.hard,
    inputModes: {ChallengeInputMode.choice},
    accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
    parameterSchema: {
      'ruleComplexity': ChallengeParameterBounds(minimum: 1, maximum: 5),
      'choiceCount': ChallengeParameterBounds(minimum: 2, maximum: 6),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    },
  );

  ChallengeModule get challengeModule => const ChallengeModule(
    metadata: metadata,
    validator: LogicChoiceValidator(),
    evaluator: LogicChoiceEvaluator(),
  );
}

final class LogicChoiceWidget extends StatefulWidget {
  const LogicChoiceWidget({
    required this.plan,
    required this.elapsed,
    required this.onAction,
    super.key,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<LogicChoiceAction> onAction;

  @override
  State<LogicChoiceWidget> createState() => _LogicChoiceWidgetState();
}

final class _LogicChoiceWidgetState extends State<LogicChoiceWidget> {
  bool _resolved = false;

  void _resolve(LogicChoiceAction action) {
    if (_resolved) return;
    _resolved = true;
    widget.onAction(action);
  }

  @override
  void didUpdateWidget(covariant LogicChoiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) _resolved = false;
  }

  @override
  Widget build(BuildContext context) {
    final timeout = Duration(
      milliseconds: widget.plan.parameters['timeoutMs']!,
    );
    if (widget.elapsed >= timeout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resolve(LogicChoiceAction.timeout(elapsed: widget.elapsed));
        }
      });
      return const Center(child: Text('Time is up'));
    }
    final puzzle = const LogicChoicePlanGenerator().puzzleFor(widget.plan);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(puzzle.prompt),
          const SizedBox(height: 16),
          for (var index = 0; index < puzzle.choices.length; index++) ...[
            Semantics(
              button: true,
              label: 'Choice ${index + 1}: ${puzzle.choices[index]}',
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => _resolve(
                    LogicChoiceAction.select(
                      choiceIndex: index,
                      elapsed: widget.elapsed,
                    ),
                  ),
                  child: Text('${puzzle.choices[index]}'),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
