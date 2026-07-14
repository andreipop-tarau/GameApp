import 'package:flutter/material.dart';

import '../../../../core/mvp_config.dart';
import '../../../../core/seeded_random.dart';
import '../../challenge.dart';

const _moduleId = 'sequence_memory';
const _moduleVersion = '1';
final DateTime _roundEpoch = DateTime.utc(2000);

const _symbols = [
  'STAR',
  'MOON',
  'LEAF',
  'WAVE',
  'SUN',
  'CLOUD',
  'HEART',
  'BOLT',
];

final class SequenceMemoryPlanGenerator {
  const SequenceMemoryPlanGenerator();

  RoundPlan generate({
    required MvpModuleConfig config,
    required MvpDifficulty difficulty,
    required int seed,
    required String configVersion,
  }) {
    if (config.id != MvpModuleId.sequenceMemory || !config.enabled) {
      throw ArgumentError.value(
        config,
        'config',
        'Sequence Memory must be enabled.',
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

    return RoundPlan(
      moduleId: _moduleId,
      moduleVersion: _moduleVersion,
      configVersion: configVersion,
      seed: seed,
      difficulty: difficulty,
      parameters: Map.unmodifiable(parameters),
    );
  }

  List<int> sequenceFor(RoundPlan plan) {
    final length = plan.parameters['sequenceLength'];
    final symbolCount = plan.parameters['symbolCount'];
    if (length == null || symbolCount == null) {
      throw ArgumentError.value(
        plan,
        'plan',
        'Sequence parameters are missing.',
      );
    }
    final random = SeededRandom(plan.seed);
    return List.unmodifiable(
      List.generate(length, (_) => random.nextInt(symbolCount)),
    );
  }
}

enum SequenceMemoryActionKind { input, timeout }

final class SequenceMemoryAction extends PlayerAction {
  SequenceMemoryAction.input({
    required List<int> symbols,
    required this.elapsed,
  }) : kind = SequenceMemoryActionKind.input,
       symbols = List.unmodifiable(symbols),
       super(_roundEpoch.add(elapsed));

  SequenceMemoryAction.timeout({required this.elapsed})
    : kind = SequenceMemoryActionKind.timeout,
      symbols = const [],
      super(_roundEpoch.add(elapsed));

  final SequenceMemoryActionKind kind;
  final List<int> symbols;
  final Duration elapsed;
}

final class SequenceMemoryValidator implements ChallengeValidator {
  const SequenceMemoryValidator();

  @override
  bool isValid(RoundPlan plan) {
    if (plan.moduleId != _moduleId || plan.moduleVersion != _moduleVersion) {
      return false;
    }
    const bounds = {
      'sequenceLength': ChallengeParameterBounds(minimum: 2, maximum: 12),
      'displayMs': ChallengeParameterBounds(minimum: 150, maximum: 2000),
      'symbolCount': ChallengeParameterBounds(minimum: 2, maximum: 8),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    };
    if (plan.parameters.length != bounds.length) return false;
    return bounds.entries.every((entry) {
      final value = plan.parameters[entry.key];
      return value != null &&
          value >= entry.value.minimum &&
          value <= entry.value.maximum;
    });
  }
}

final class SequenceMemoryEvaluator implements ChallengeEvaluator {
  const SequenceMemoryEvaluator();

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    if (action is! SequenceMemoryAction) {
      throw ArgumentError.value(
        action,
        'action',
        'Sequence Memory requires its action type.',
      );
    }
    final presentation = Duration(
      milliseconds:
          plan.parameters['sequenceLength']! * plan.parameters['displayMs']!,
    );
    final timeout = Duration(milliseconds: plan.parameters['timeoutMs']!);
    final elapsed = currentRoundTime.difference(_roundEpoch);
    final expected = const SequenceMemoryPlanGenerator().sequenceFor(plan);
    final success =
        action.kind == SequenceMemoryActionKind.input &&
        elapsed >= presentation &&
        elapsed < presentation + timeout &&
        _matches(expected, action.symbols);

    return RoundEvaluation(
      outcome: success ? ChallengeOutcome.success : ChallengeOutcome.failure,
      metrics: RoundMetrics(
        responseTime: elapsed > presentation
            ? elapsed - presentation
            : Duration.zero,
        actionCount: 1,
      ),
    );
  }

  bool _matches(List<int> expected, List<int> actual) {
    if (expected.length != actual.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (expected[index] != actual[index]) return false;
    }
    return true;
  }
}

final class SequenceMemoryModule {
  const SequenceMemoryModule();

  static const metadata = ChallengeMetadata(
    id: _moduleId,
    version: _moduleVersion,
    category: ChallengeCategory.memory,
    minimumDifficulty: MvpDifficulty.easy,
    maximumDifficulty: MvpDifficulty.hard,
    inputModes: {ChallengeInputMode.sequence},
    accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
    parameterSchema: {
      'sequenceLength': ChallengeParameterBounds(minimum: 2, maximum: 12),
      'displayMs': ChallengeParameterBounds(minimum: 150, maximum: 2000),
      'symbolCount': ChallengeParameterBounds(minimum: 2, maximum: 8),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    },
  );

  ChallengeModule get challengeModule => const ChallengeModule(
    metadata: metadata,
    validator: SequenceMemoryValidator(),
    evaluator: SequenceMemoryEvaluator(),
  );
}

final class SequenceMemoryWidget extends StatefulWidget {
  const SequenceMemoryWidget({
    required this.plan,
    required this.elapsed,
    required this.onAction,
    super.key,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<SequenceMemoryAction> onAction;

  @override
  State<SequenceMemoryWidget> createState() => _SequenceMemoryWidgetState();
}

final class _SequenceMemoryWidgetState extends State<SequenceMemoryWidget> {
  bool _resolved = false;
  List<int> _input = const [];

  void _resolve(SequenceMemoryAction action) {
    if (_resolved) return;
    _resolved = true;
    widget.onAction(action);
  }

  @override
  void didUpdateWidget(covariant SequenceMemoryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _resolved = false;
      _input = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequence = const SequenceMemoryPlanGenerator().sequenceFor(
      widget.plan,
    );
    final displayMs = widget.plan.parameters['displayMs']!;
    final presentation = Duration(milliseconds: sequence.length * displayMs);
    final timeout = Duration(
      milliseconds: widget.plan.parameters['timeoutMs']!,
    );

    if (widget.elapsed >= presentation + timeout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resolve(SequenceMemoryAction.timeout(elapsed: widget.elapsed));
        }
      });
      return const Center(child: Text('Time is up'));
    }

    if (widget.elapsed < presentation) {
      final symbolIndex = widget.elapsed.inMilliseconds ~/ displayMs;
      final symbol = _symbols[sequence[symbolIndex]];
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remember this symbol: $symbol'),
            Text('Step ${symbolIndex + 1} of ${sequence.length}'),
            const SizedBox(height: 16),
            const Text('Input is disabled while the sequence is shown.'),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Repeat the sequence: ${_input.length} of ${sequence.length}'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(widget.plan.parameters['symbolCount']!, (
            index,
          ) {
            final symbol = _symbols[index];
            return Semantics(
              button: true,
              label: 'Symbol ${index + 1}: $symbol',
              child: SizedBox(
                width: 72,
                height: 52,
                child: FilledButton(
                  onPressed: () => _selectSymbol(index, sequence),
                  child: Text(symbol),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _selectSymbol(int symbol, List<int> expected) {
    if (_resolved) return;
    final nextInput = [..._input, symbol];
    final isWrong = expected[_input.length] != symbol;
    if (isWrong || nextInput.length == expected.length) {
      _resolve(
        SequenceMemoryAction.input(symbols: nextInput, elapsed: widget.elapsed),
      );
      return;
    }
    setState(() => _input = List.unmodifiable(nextInput));
  }
}
