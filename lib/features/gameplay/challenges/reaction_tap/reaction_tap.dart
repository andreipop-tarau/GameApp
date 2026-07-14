import 'package:flutter/material.dart';

import '../../../../core/mvp_config.dart';
import '../../../../core/seeded_random.dart';
import '../../challenge.dart';

const _moduleId = 'reaction_tap';
const _moduleVersion = '1';

final class ReactionTapPlanGenerator {
  const ReactionTapPlanGenerator();

  RoundPlan generate({
    required MvpModuleConfig config,
    required MvpDifficulty difficulty,
    required int seed,
    required String configVersion,
  }) {
    if (config.id != MvpModuleId.reactionTap || !config.enabled) {
      throw ArgumentError.value(
        config,
        'config',
        'Reaction Tap must be enabled.',
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
}

enum ReactionTapActionKind { target, distractor, timeout }

final class ReactionTapAction extends PlayerAction {
  ReactionTapAction({required this.kind, required this.elapsed})
    : super(_roundEpoch.add(elapsed));

  final ReactionTapActionKind kind;
  final Duration elapsed;
}

final class ReactionTapValidator implements ChallengeValidator {
  const ReactionTapValidator();

  @override
  bool isValid(RoundPlan plan) {
    if (plan.moduleId != _moduleId || plan.moduleVersion != _moduleVersion) {
      return false;
    }
    const bounds = {
      'cueDelayMs': ChallengeParameterBounds(minimum: 300, maximum: 3000),
      'targetSizePx': ChallengeParameterBounds(minimum: 32, maximum: 160),
      'distractorCount': ChallengeParameterBounds(minimum: 0, maximum: 8),
      'timeoutMs': ChallengeParameterBounds(minimum: 500, maximum: 10000),
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

final class ReactionTapEvaluator implements ChallengeEvaluator {
  const ReactionTapEvaluator();

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    if (action is! ReactionTapAction) {
      throw ArgumentError.value(
        action,
        'action',
        'Reaction Tap requires its action type.',
      );
    }
    final cueDelay = Duration(milliseconds: plan.parameters['cueDelayMs']!);
    final timeout = Duration(milliseconds: plan.parameters['timeoutMs']!);
    final elapsed = currentRoundTime.difference(_roundEpoch);
    final responseTime = elapsed > cueDelay
        ? elapsed - cueDelay
        : Duration.zero;
    final isTimedOut =
        action.kind == ReactionTapActionKind.timeout ||
        elapsed >= cueDelay + timeout;
    final success =
        !isTimedOut &&
        elapsed >= cueDelay &&
        action.kind == ReactionTapActionKind.target;

    return RoundEvaluation(
      outcome: success ? ChallengeOutcome.success : ChallengeOutcome.failure,
      metrics: RoundMetrics(responseTime: responseTime, actionCount: 1),
    );
  }
}

final class ReactionTapModule {
  const ReactionTapModule();

  static const metadata = ChallengeMetadata(
    id: _moduleId,
    version: _moduleVersion,
    category: ChallengeCategory.reaction,
    minimumDifficulty: MvpDifficulty.easy,
    maximumDifficulty: MvpDifficulty.hard,
    inputModes: {ChallengeInputMode.tap},
    accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
    parameterSchema: {
      'cueDelayMs': ChallengeParameterBounds(minimum: 300, maximum: 3000),
      'targetSizePx': ChallengeParameterBounds(minimum: 32, maximum: 160),
      'distractorCount': ChallengeParameterBounds(minimum: 0, maximum: 8),
      'timeoutMs': ChallengeParameterBounds(minimum: 500, maximum: 10000),
    },
  );

  ChallengeModule get challengeModule => const ChallengeModule(
    metadata: metadata,
    validator: ReactionTapValidator(),
    evaluator: ReactionTapEvaluator(),
  );
}

final class ReactionTapWidget extends StatefulWidget {
  const ReactionTapWidget({
    required this.plan,
    required this.elapsed,
    required this.onAction,
    super.key,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<ReactionTapAction> onAction;

  @override
  State<ReactionTapWidget> createState() => _ReactionTapWidgetState();
}

final class _ReactionTapWidgetState extends State<ReactionTapWidget> {
  bool _resolved = false;

  void _resolve(ReactionTapActionKind kind) {
    if (_resolved) return;
    _resolved = true;
    widget.onAction(ReactionTapAction(kind: kind, elapsed: widget.elapsed));
  }

  @override
  void didUpdateWidget(covariant ReactionTapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) _resolved = false;
  }

  @override
  Widget build(BuildContext context) {
    final cueDelay = Duration(
      milliseconds: widget.plan.parameters['cueDelayMs']!,
    );
    final timeout = Duration(
      milliseconds: widget.plan.parameters['timeoutMs']!,
    );
    if (widget.elapsed >= cueDelay + timeout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _resolve(ReactionTapActionKind.timeout);
      });
      return const Center(child: Text('Time is up'));
    }

    if (widget.elapsed < cueDelay) {
      return Center(
        child: Semantics(
          button: true,
          label: 'Wait for the GO cue. Tapping now loses the round.',
          child: FilledButton(
            onPressed: () => _resolve(ReactionTapActionKind.target),
            child: const Text('WAIT'),
          ),
        ),
      );
    }

    final itemCount = widget.plan.parameters['distractorCount']! + 1;
    final targetIndex = SeededRandom(widget.plan.seed).nextInt(itemCount);
    final targetSize = widget.plan.parameters['targetSizePx']!.toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('GO — tap the GO target'),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(itemCount, (index) {
            final isTarget = index == targetIndex;
            final label = isTarget ? 'GO target' : 'WAIT distractor';
            return Semantics(
              button: true,
              label: label,
              child: SizedBox(
                width: targetSize.clamp(44, 160),
                height: targetSize.clamp(44, 160),
                child: FilledButton(
                  onPressed: () => _resolve(
                    isTarget
                        ? ReactionTapActionKind.target
                        : ReactionTapActionKind.distractor,
                  ),
                  child: Text(isTarget ? 'GO' : 'WAIT'),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

final DateTime _roundEpoch = DateTime.utc(2000);
