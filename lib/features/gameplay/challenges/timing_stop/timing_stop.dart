import 'package:flutter/material.dart';

import '../../../../core/mvp_config.dart';
import '../../../../core/seeded_random.dart';
import '../../challenge.dart';

const _moduleId = 'timing_stop';
const _moduleVersion = '1';
final DateTime _roundEpoch = DateTime.utc(2000);

final class TimingStopZone {
  const TimingStopZone({required this.start, required this.end});

  final int start;
  final int end;

  bool contains(int position) => position >= start && position <= end;
}

enum TimingStopDirection { left, right }

final class TimingStopPlanGenerator {
  const TimingStopPlanGenerator();

  RoundPlan generate({
    required MvpModuleConfig config,
    required MvpDifficulty difficulty,
    required int seed,
    required String configVersion,
  }) {
    if (config.id != MvpModuleId.timingStop || !config.enabled) {
      throw ArgumentError.value(
        config,
        'config',
        'Timing Stop must be enabled.',
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
    if (!const TimingStopValidator().isValid(plan)) {
      throw StateError('Generated Timing Stop plan is invalid.');
    }
    return plan;
  }

  TimingStopZone zoneFor(RoundPlan plan) {
    final zoneSize = plan.parameters['zoneSize'];
    if (zoneSize == null || zoneSize < 5 || zoneSize > 80) {
      throw ArgumentError.value(plan, 'plan', 'Zone size is invalid.');
    }
    final width = zoneSize * 10;
    final start = SeededRandom(plan.seed).nextInt(1001 - width);
    return TimingStopZone(start: start, end: start + width);
  }

  TimingStopDirection initialDirectionFor(RoundPlan plan) {
    final random = SeededRandom(plan.seed);
    random.nextInt(1001);
    return random.nextBool()
        ? TimingStopDirection.right
        : TimingStopDirection.left;
  }
}

final class TimingStopMotion {
  const TimingStopMotion();

  static const _directionChangeInterval = Duration(seconds: 1);

  int positionAt(RoundPlan plan, Duration elapsed) {
    if (elapsed.isNegative) {
      throw ArgumentError.value(
        elapsed,
        'elapsed',
        'Elapsed time is negative.',
      );
    }
    final speed = plan.parameters['speed'];
    final directionChanges = plan.parameters['directionChanges'];
    if (speed == null || directionChanges == null) {
      throw ArgumentError.value(plan, 'plan', 'Motion parameters are invalid.');
    }

    final random = SeededRandom(plan.seed);
    final initialPosition = random.nextInt(1001);
    var position = initialPosition;
    var direction = random.nextBool() ? 1 : -1;
    var remainingMilliseconds = elapsed.inMilliseconds;
    var completedChanges = 0;
    final intervalMilliseconds = _directionChangeInterval.inMilliseconds;

    while (remainingMilliseconds > 0) {
      final segmentMilliseconds = remainingMilliseconds > intervalMilliseconds
          ? intervalMilliseconds
          : remainingMilliseconds;
      final distance = (speed * segmentMilliseconds) ~/ 100;
      position = (position + direction * distance) % 1001;
      if (position < 0) position += 1001;
      remainingMilliseconds -= segmentMilliseconds;
      if (remainingMilliseconds > 0 && completedChanges < directionChanges) {
        direction = -direction;
        completedChanges++;
      }
    }
    return position;
  }

  TimingStopDirection directionAt(RoundPlan plan, Duration elapsed) {
    if (elapsed.isNegative) {
      throw ArgumentError.value(
        elapsed,
        'elapsed',
        'Elapsed time is negative.',
      );
    }
    final changesElapsed =
        elapsed.inMilliseconds ~/ _directionChangeInterval.inMilliseconds;
    final directionChanges = plan.parameters['directionChanges']!;
    final flips = changesElapsed < directionChanges
        ? changesElapsed
        : directionChanges;
    final initial = const TimingStopPlanGenerator().initialDirectionFor(plan);
    final pointsRight = initial == TimingStopDirection.right;
    final isRight = flips.isEven ? pointsRight : !pointsRight;
    return isRight ? TimingStopDirection.right : TimingStopDirection.left;
  }
}

final class TimingStopAction extends PlayerAction {
  TimingStopAction.tap({required this.elapsed})
    : super(_roundEpoch.add(elapsed));

  final Duration elapsed;
}

final class TimingStopValidator implements ChallengeValidator {
  const TimingStopValidator();

  @override
  bool isValid(RoundPlan plan) {
    if (plan.moduleId != _moduleId || plan.moduleVersion != _moduleVersion) {
      return false;
    }
    const bounds = {
      'speed': ChallengeParameterBounds(minimum: 1, maximum: 100),
      'zoneSize': ChallengeParameterBounds(minimum: 5, maximum: 80),
      'directionChanges': ChallengeParameterBounds(minimum: 0, maximum: 10),
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
    final zone = const TimingStopPlanGenerator().zoneFor(plan);
    return zone.start >= 0 && zone.end <= 1000 && zone.start < zone.end;
  }
}

final class TimingStopEvaluator implements ChallengeEvaluator {
  const TimingStopEvaluator();

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    if (action is! TimingStopAction) {
      throw ArgumentError.value(
        action,
        'action',
        'Timing Stop requires its action type.',
      );
    }
    if (!const TimingStopValidator().isValid(plan)) {
      throw ArgumentError.value(plan, 'plan', 'Timing Stop plan is invalid.');
    }
    final position = const TimingStopMotion().positionAt(plan, action.elapsed);
    final success = const TimingStopPlanGenerator()
        .zoneFor(plan)
        .contains(position);
    return RoundEvaluation(
      outcome: success ? ChallengeOutcome.success : ChallengeOutcome.failure,
      metrics: RoundMetrics(responseTime: action.elapsed, actionCount: 1),
    );
  }
}

final class TimingStopModule {
  const TimingStopModule();

  static const metadata = ChallengeMetadata(
    id: _moduleId,
    version: _moduleVersion,
    category: ChallengeCategory.timing,
    minimumDifficulty: MvpDifficulty.easy,
    maximumDifficulty: MvpDifficulty.hard,
    inputModes: {ChallengeInputMode.tap},
    accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
    parameterSchema: {
      'speed': ChallengeParameterBounds(minimum: 1, maximum: 100),
      'zoneSize': ChallengeParameterBounds(minimum: 5, maximum: 80),
      'directionChanges': ChallengeParameterBounds(minimum: 0, maximum: 10),
    },
  );

  ChallengeModule get challengeModule => const ChallengeModule(
    metadata: metadata,
    validator: TimingStopValidator(),
    evaluator: TimingStopEvaluator(),
  );
}

final class TimingStopWidget extends StatefulWidget {
  const TimingStopWidget({
    required this.plan,
    required this.elapsed,
    required this.onAction,
    super.key,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<TimingStopAction> onAction;

  @override
  State<TimingStopWidget> createState() => _TimingStopWidgetState();
}

final class _TimingStopWidgetState extends State<TimingStopWidget> {
  bool _resolved = false;

  void _resolve() {
    if (_resolved) return;
    _resolved = true;
    widget.onAction(TimingStopAction.tap(elapsed: widget.elapsed));
  }

  @override
  void didUpdateWidget(covariant TimingStopWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) _resolved = false;
  }

  @override
  Widget build(BuildContext context) {
    final generator = const TimingStopPlanGenerator();
    final motion = const TimingStopMotion();
    final zone = generator.zoneFor(widget.plan);
    final position = motion.positionAt(widget.plan, widget.elapsed);
    final direction = motion.directionAt(widget.plan, widget.elapsed);
    final positionPercent = (position / 10).toStringAsFixed(0);
    final zoneStartPercent = (zone.start / 10).toStringAsFixed(0);
    final zoneEndPercent = (zone.end / 10).toStringAsFixed(0);
    final directionText = direction == TimingStopDirection.right
        ? 'right'
        : 'left';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Stop the marker inside the target zone.'),
        const SizedBox(height: 12),
        Text('Target zone: $zoneStartPercent% to $zoneEndPercent%'),
        Text('Marker: $positionPercent%, moving $directionText'),
        const SizedBox(height: 16),
        Semantics(
          label:
              'Timing track. Target zone from $zoneStartPercent to $zoneEndPercent percent. Marker at $positionPercent percent, moving $directionText.',
          child: SizedBox(
            height: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Positioned(
                      left: width * zone.start / 1000,
                      width: width * (zone.end - zone.start) / 1000,
                      top: 4,
                      bottom: 4,
                      child: const Center(child: Text('TARGET ZONE')),
                    ),
                    Positioned(
                      left: (width * position / 1000 - 12)
                          .clamp(0, width - 24)
                          .toDouble(),
                      top: 12,
                      child: const Icon(Icons.arrow_drop_down, size: 24),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: 'Stop marker at $positionPercent percent',
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(onPressed: _resolve, child: const Text('STOP')),
          ),
        ),
      ],
    );
  }
}
