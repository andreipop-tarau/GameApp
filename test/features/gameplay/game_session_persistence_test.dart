import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/local_game_save.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_provider.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/logic_choice/logic_choice.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/reaction_tap/reaction_tap.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/selective_attention/selective_attention.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/sequence_memory/sequence_memory.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/timing_stop/timing_stop.dart';
import 'package:mindtrap_ai/features/gameplay/game_session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<MvpConfig> loadTestConfig() async {
    final result = parseMvpConfig(
      File('assets/config/mvp_challenges.json').readAsStringSync(),
    );
    return (result as MvpConfigLoaded).config;
  }

  PlayerAction actionFor(RoundPlan plan) => switch (plan.moduleId) {
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

  test(
    'persists each completed outcome once and caps recent history',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = LocalGameSaveStore(await SharedPreferences.getInstance());
      final container = ProviderContainer(
        overrides: [
          gameSessionControllerProvider.overrideWith(
            () => GameSessionController(configLoader: loadTestConfig),
          ),
          localGameSaveStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(gameSessionControllerProvider.notifier);

      for (var index = 0; index < LocalGameSave.historyLimit + 1; index++) {
        await controller.startRound();
        final plan = container.read(gameSessionControllerProvider).plan!;
        controller.submit(actionFor(plan), Duration.zero);
      }
      await Future<void>.delayed(Duration.zero);

      final loaded = await store.load();
      expect(loaded.status, LocalGameSaveLoadStatus.loaded);
      expect(loaded.save.recentOutcomes, hasLength(LocalGameSave.historyLimit));
      expect(
        loaded.save.brainProfile.totalSampleCount,
        LocalGameSave.historyLimit + 1,
      );
      expect(
        loaded.save.recentOutcomes.map((outcome) => outcome.id).toSet(),
        hasLength(LocalGameSave.historyLimit),
      );

      final restored = ProviderContainer(
        overrides: [
          initialBrainProfileProvider.overrideWithValue(
            loaded.save.brainProfile,
          ),
          initialLocalGameSaveProvider.overrideWithValue(loaded.save),
        ],
      );
      addTearDown(restored.dispose);
      expect(
        restored.read(brainProfileProvider).totalSampleCount,
        LocalGameSave.historyLimit + 1,
      );
    },
  );
}
