import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_provider.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_updater.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/logic_choice/logic_choice.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/reaction_tap/reaction_tap.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/selective_attention/selective_attention.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/sequence_memory/sequence_memory.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/timing_stop/timing_stop.dart';
import 'package:mindtrap_ai/features/gameplay/game_session_controller.dart';

void main() {
  Future<MvpConfig> loadTestConfig() async {
    final result = parseMvpConfig(
      File('assets/config/mvp_challenges.json').readAsStringSync(),
    );
    return (result as MvpConfigLoaded).config;
  }

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      gameSessionControllerProvider.overrideWith(
        () => GameSessionController(configLoader: loadTestConfig),
      ),
    ],
  );

  test('session begins with a deterministic five-module rotation', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    final controller = container.read(gameSessionControllerProvider.notifier);
    final moduleIds = <String>[];
    final plans = <RoundPlan>[];

    for (var index = 0; index < 5; index++) {
      await controller.startRound();
      final plan = container.read(gameSessionControllerProvider).plan!;
      plans.add(plan);
      moduleIds.add(plan.moduleId);
    }

    expect(moduleIds.toSet(), {
      'reaction_tap',
      'sequence_memory',
      'selective_attention',
      'timing_stop',
      'logic_choice',
    });
    expect(
      plans.every(
        (plan) =>
            plan.policyVersion == 'ai-director-v1' &&
            plan.selectionReason != null,
      ),
      isTrue,
    );
  });

  test('session preserves the first resolution', () async {
    final container = createContainer();
    addTearDown(container.dispose);
    final controller = container.read(gameSessionControllerProvider.notifier);

    await controller.startRound();
    final plan = container.read(gameSessionControllerProvider).plan!;
    final action = switch (plan.moduleId) {
      'reaction_tap' => ReactionTapAction(
        kind: ReactionTapActionKind.target,
        elapsed: Duration.zero,
      ),
      'sequence_memory' => SequenceMemoryAction.input(
        symbols: const [0],
        elapsed: Duration.zero,
      ),
      'selective_attention' => SelectiveAttentionAction.select(
        itemId: 0,
        elapsed: Duration.zero,
      ),
      'timing_stop' => TimingStopAction.tap(elapsed: Duration.zero),
      'logic_choice' => LogicChoiceAction.select(
        choiceIndex: 0,
        elapsed: Duration.zero,
      ),
      _ => throw StateError('Unexpected module.'),
    };
    final updatedSkill = brainSkillForChallengeCategory(
      container.read(gameSessionControllerProvider).module!.metadata.category,
    );

    controller.submit(action, Duration.zero);
    final first = container.read(gameSessionControllerProvider).evaluation;
    final firstProfile = container.read(brainProfileProvider);
    controller.submit(action, Duration.zero);

    expect(
      container.read(gameSessionControllerProvider).evaluation,
      same(first),
    );
    expect(firstProfile.estimateFor(updatedSkill).sampleCount, 1);
    expect(
      container
          .read(brainProfileProvider)
          .estimateFor(updatedSkill)
          .sampleCount,
      1,
    );
  });
}
