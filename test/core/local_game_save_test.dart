import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/local_game_save.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_updater.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';
import 'package:mindtrap_ai/features/progression/progression.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  LocalGameSave populatedSave() {
    const updater = BrainProfileUpdater();
    final profile = updater
        .apply(
          const BrainProfile.initial(),
          const BrainProfileOutcome(
            id: 'classic:1009:1009',
            category: ChallengeCategory.reaction,
            performance: 100,
            status: BrainProfileOutcomeStatus.completed,
          ),
        )
        .profile;
    return LocalGameSave(
      brainProfile: profile,
      progression: Progression(
        totalXp: 10,
        level: 1,
        appliedOutcomeIds: {'classic:1009:1009'},
      ),
      recentOutcomes: const [
        LocalRoundOutcome(
          id: 'classic:1009:1009',
          moduleId: 'reaction_tap',
          difficulty: 'easy',
          wasSuccessful: true,
        ),
      ],
    );
  }

  test('round-trips one versioned save document', () {
    final decoded = LocalGameSave.decode(jsonEncode(populatedSave().toJson()));

    expect(decoded.status, LocalGameSaveLoadStatus.loaded);
    expect(decoded.save.brainProfile.reaction.sampleCount, 1);
    expect(
      decoded.save.brainProfile.hasAppliedOutcome('classic:1009:1009'),
      isTrue,
    );
    expect(decoded.save.recentOutcomes.single.wasSuccessful, isTrue);
    expect(decoded.save.progression.totalXp, 10);
  });

  test('recovers safely from empty, corrupt, and unsupported saves', () async {
    SharedPreferences.setMockInitialValues({});
    final emptyStore = LocalGameSaveStore(
      await SharedPreferences.getInstance(),
    );
    expect((await emptyStore.load()).status, LocalGameSaveLoadStatus.empty);

    SharedPreferences.setMockInitialValues({
      localGameSavePreferenceKey: '{bad',
    });
    final corruptStore = LocalGameSaveStore(
      await SharedPreferences.getInstance(),
    );
    expect((await corruptStore.load()).status, LocalGameSaveLoadStatus.corrupt);

    SharedPreferences.setMockInitialValues({
      localGameSavePreferenceKey: jsonEncode({
        'schemaVersion': 2,
        'brainProfile': {},
        'recentOutcomes': [],
      }),
    });
    final unsupportedStore = LocalGameSaveStore(
      await SharedPreferences.getInstance(),
    );
    final unsupported = await unsupportedStore.load();
    expect(unsupported.status, LocalGameSaveLoadStatus.unsupported);
    expect(unsupported.save.brainProfile.totalSampleCount, 0);
  });
}
