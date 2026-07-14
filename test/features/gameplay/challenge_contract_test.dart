import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenge_catalog.dart';
import 'package:mindtrap_ai/features/gameplay/round_lifecycle.dart';

import '../../fixtures/fake_challenge_module.dart';

void main() {
  final actionTime = DateTime.utc(2026, 7, 14, 12);
  final resolvedTime = DateTime.utc(2026, 7, 14, 12, 0, 1);

  RoundPlan plan({int valid = 1}) => RoundPlan(
    moduleId: 'fake_challenge',
    moduleVersion: '1',
    configVersion: '1.0.0',
    seed: 42,
    difficulty: MvpDifficulty.easy,
    parameters: {'valid': valid},
  );

  test('catalog explicitly registers a module', () {
    final fake = FakeChallengeModule();
    final catalog = ChallengeCatalog([fake.module]);

    expect(catalog.findById('fake_challenge'), same(fake.module));
    expect(catalog.findById('missing'), isNull);
  });

  test('catalog rejects duplicate module IDs', () {
    final first = FakeChallengeModule();
    final second = FakeChallengeModule();

    expect(
      () => ChallengeCatalog([first.module, second.module]),
      throwsArgumentError,
    );
  });

  test('invalid plans are rejected before lifecycle starts', () {
    final fake = FakeChallengeModule();

    expect(
      () => RoundLifecycle(plan: plan(valid: 0), module: fake.module),
      throwsArgumentError,
    );
  });

  test('resolution evaluates once and keeps the first outcome', () {
    final fake = FakeChallengeModule();
    final lifecycle = RoundLifecycle(plan: plan(), module: fake.module);
    lifecycle.beginBriefing();
    lifecycle.beginActive();

    final first = lifecycle.resolve(FakePlayerAction(actionTime), resolvedTime);
    final second = lifecycle.resolve(
      FakePlayerAction(actionTime),
      resolvedTime,
    );

    expect(second, same(first));
    expect(fake.evaluator.evaluationCount, 1);
    expect(lifecycle.state, RoundLifecycleState.resolved);
    expect(first.metrics.responseTime, const Duration(seconds: 1));
  });
}
