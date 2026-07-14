import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/timing_stop/timing_stop.dart';

void main() {
  const generator = TimingStopPlanGenerator();
  const config = MvpModuleConfig(
    id: MvpModuleId.timingStop,
    enabled: true,
    difficultyBands: {
      MvpDifficulty.easy: {'speed': 25, 'zoneSize': 20, 'directionChanges': 2},
      MvpDifficulty.medium: {
        'speed': 50,
        'zoneSize': 15,
        'directionChanges': 4,
      },
      MvpDifficulty.hard: {'speed': 80, 'zoneSize': 10, 'directionChanges': 8},
    },
  );

  RoundPlan plan() => generator.generate(
    config: config,
    difficulty: MvpDifficulty.medium,
    seed: 123,
    configVersion: '1.0.0',
  );

  test('seeded generation and zone boundaries are stable', () {
    final first = plan();
    final second = plan();
    final firstZone = generator.zoneFor(first);
    final secondZone = generator.zoneFor(second);

    expect(second.parameters, first.parameters);
    expect(secondZone.start, firstZone.start);
    expect(secondZone.end, firstZone.end);
    expect(const TimingStopValidator().isValid(first), isTrue);
  });

  test('validator rejects invalid speed, zone size, and direction changes', () {
    for (final parameters in [
      {'speed': 0, 'zoneSize': 20, 'directionChanges': 1},
      {'speed': 50, 'zoneSize': 81, 'directionChanges': 1},
      {'speed': 50, 'zoneSize': 20, 'directionChanges': 11},
    ]) {
      expect(
        const TimingStopValidator().isValid(
          RoundPlan(
            moduleId: 'timing_stop',
            moduleVersion: '1',
            configVersion: '1.0.0',
            seed: 1,
            difficulty: MvpDifficulty.easy,
            parameters: parameters,
          ),
        ),
        isFalse,
      );
    }
  });

  test(
    'fake clock controls elapsed-time position independently of frame count',
    () {
      final motion = const TimingStopMotion();
      final round = plan();
      var fakeElapsed = Duration.zero;

      final atStart = motion.positionAt(round, fakeElapsed);
      fakeElapsed = const Duration(milliseconds: 750);
      final afterElapsed = motion.positionAt(round, fakeElapsed);

      expect(motion.positionAt(round, Duration.zero), atStart);
      expect(motion.positionAt(round, fakeElapsed), afterElapsed);
      expect(afterElapsed, isNot(atStart));
      expect(
        motion.directionAt(round, const Duration(seconds: 1)),
        isNot(motion.directionAt(round, Duration.zero)),
      );
    },
  );

  test('tap evaluation uses the fake-clock position and target zone', () {
    final round = plan();
    final zone = generator.zoneFor(round);
    final motion = const TimingStopMotion();
    final evaluator = const TimingStopEvaluator();
    final epoch = DateTime.utc(2000);
    final elapsed = Iterable<Duration>.generate(
      10000,
      (milliseconds) => Duration(milliseconds: milliseconds),
    ).firstWhere((value) => zone.contains(motion.positionAt(round, value)));

    final evaluation = evaluator.evaluate(
      plan: round,
      action: TimingStopAction.tap(elapsed: elapsed),
      currentRoundTime: epoch.add(elapsed),
    );

    expect(evaluation.outcome, ChallengeOutcome.success);
    expect(evaluation.metrics.responseTime, elapsed);
  });
}
