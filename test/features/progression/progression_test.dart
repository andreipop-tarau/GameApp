import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/progression/progression.dart';

void main() {
  const config = MvpProgressionConfig(
    xpByDifficulty: {
      MvpDifficulty.easy: 10,
      MvpDifficulty.medium: 20,
      MvpDifficulty.hard: 35,
    },
    levelXpThresholds: [0, 10, 30, 65],
  );
  const rules = ProgressionRules();

  test('uses config XP once per eligible outcome', () {
    final first = rules.apply(
      progression: const Progression.initial(),
      outcome: const ProgressionOutcome(
        id: 'round-1',
        difficulty: MvpDifficulty.medium,
        isEligible: true,
      ),
      config: config,
    );
    final duplicate = rules.apply(
      progression: first.progression,
      outcome: const ProgressionOutcome(
        id: 'round-1',
        difficulty: MvpDifficulty.hard,
        isEligible: true,
      ),
      config: config,
    );

    expect(first.xpDelta, 20);
    expect(first.progression.totalXp, 20);
    expect(duplicate.wasApplied, isFalse);
    expect(duplicate.xpDelta, 0);
    expect(duplicate.progression.totalXp, 20);
  });

  test('level progression is monotonic', () {
    final awarded = rules.apply(
      progression: Progression(totalXp: 25, level: 3, appliedOutcomeIds: {}),
      outcome: const ProgressionOutcome(
        id: 'round-2',
        difficulty: MvpDifficulty.easy,
        isEligible: true,
      ),
      config: config,
    );

    expect(awarded.progression.level, 3);
    expect(awarded.progression.totalXp, 35);
  });
}
