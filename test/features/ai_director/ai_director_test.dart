import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/ai_director/ai_director.dart';
import 'package:mindtrap_ai/features/ai_director/difficulty_policy.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile.dart';

void main() {
  const director = AiDirector();

  MvpModuleConfig module(
    MvpModuleId id, {
    bool enabled = true,
    Iterable<MvpDifficulty> difficulties = MvpDifficulty.values,
  }) {
    return MvpModuleConfig(
      id: id,
      enabled: enabled,
      difficultyBands: {
        for (final difficulty in difficulties)
          difficulty: const <String, int>{},
      },
    );
  }

  MvpConfig config(Iterable<MvpModuleConfig> modules) {
    return MvpConfig(
      schemaVersion: 1,
      contentVersion: 'test-v1',
      modules: modules.toList(growable: false),
    );
  }

  AiDirectorRequest request({
    required MvpConfig config,
    Iterable<AiDirectorRoundHistory> history = const [],
    int consecutiveFailures = 0,
    int seed = 41,
  }) {
    return AiDirectorRequest(
      config: config,
      profile: const BrainProfile.initial(),
      recentHistory: history,
      consecutiveFailures: consecutiveFailures,
      seed: seed,
    );
  }

  test('filters disabled modules', () {
    final selection = director.select(
      request(
        config: config([
          module(MvpModuleId.reactionTap, enabled: false),
          module(MvpModuleId.sequenceMemory),
        ]),
      ),
    );

    expect(selection.module.id, MvpModuleId.sequenceMemory);
  });

  test('returns the only valid candidate', () {
    final selection = director.select(
      request(config: config([module(MvpModuleId.logicChoice)])),
    );

    expect(selection.module.id, MvpModuleId.logicChoice);
    expect(selection.reason, AiDirectorSelectionReason.onlyCandidate);
  });

  test('avoids the most recent module when an alternative exists', () {
    final selection = director.select(
      request(
        config: config([
          module(MvpModuleId.reactionTap),
          module(MvpModuleId.sequenceMemory),
        ]),
        history: const [
          AiDirectorRoundHistory(
            moduleId: MvpModuleId.reactionTap,
            difficulty: MvpDifficulty.easy,
            wasSuccessful: true,
          ),
        ],
      ),
    );

    expect(selection.module.id, MvpModuleId.sequenceMemory);
  });

  test('cold start rotates through all available categories', () {
    final testConfig = config([
      for (final id in MvpModuleId.values) module(id),
    ]);
    final history = <AiDirectorRoundHistory>[];
    final selectedIds = <MvpModuleId>[];

    for (var round = 0; round < MvpModuleId.values.length; round++) {
      final selection = director.select(
        request(config: testConfig, history: history, seed: 100 + round),
      );
      selectedIds.add(selection.module.id);
      history.add(
        AiDirectorRoundHistory(
          moduleId: selection.module.id,
          difficulty: selection.difficulty,
        ),
      );
    }

    expect(selectedIds.toSet(), MvpModuleId.values.toSet());
  });

  test('three failures select an easier recovery candidate', () {
    final selection = director.select(
      request(
        config: config([
          module(MvpModuleId.reactionTap),
          module(MvpModuleId.sequenceMemory),
        ]),
        history: const [
          AiDirectorRoundHistory(
            moduleId: MvpModuleId.reactionTap,
            difficulty: MvpDifficulty.hard,
            wasSuccessful: false,
          ),
        ],
        consecutiveFailures: 3,
      ),
    );

    expect(selection.module.id, MvpModuleId.sequenceMemory);
    expect(selection.difficulty, MvpDifficulty.medium);
    expect(selection.reason, AiDirectorSelectionReason.recovery);
  });

  test('difficulty stays bounded and changes by at most one step', () {
    const policy = DifficultyPolicy();
    const strongSkill = BrainSkillEstimate(
      value: 100,
      confidence: 1,
      sampleCount: 10,
    );
    const weakSkill = BrainSkillEstimate(
      value: 0,
      confidence: 1,
      sampleCount: 10,
    );

    expect(
      policy.select(
        skill: strongSkill,
        allowedDifficulties: MvpDifficulty.values,
        previousDifficulty: MvpDifficulty.easy,
        consecutiveFailures: 0,
        lastRoundSucceeded: true,
      ),
      MvpDifficulty.medium,
    );
    expect(
      policy.select(
        skill: weakSkill,
        allowedDifficulties: const [MvpDifficulty.medium, MvpDifficulty.hard],
        previousDifficulty: MvpDifficulty.medium,
        consecutiveFailures: 3,
        lastRoundSucceeded: false,
      ),
      MvpDifficulty.medium,
    );
  });

  test('same input and seed return the same selection', () {
    final directorRequest = request(
      config: config([for (final id in MvpModuleId.values) module(id)]),
      seed: 8128,
    );

    final first = director.select(directorRequest);
    final second = director.select(directorRequest);

    expect(second.module.id, first.module.id);
    expect(second.difficulty, first.difficulty);
    expect(second.reason, first.reason);
    expect(second.policyVersion, first.policyVersion);
  });
}
