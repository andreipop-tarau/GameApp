import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile.dart';
import 'package:mindtrap_ai/features/brain_profile/brain_profile_updater.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';

void main() {
  const updater = BrainProfileUpdater();

  BrainProfileOutcome outcome({
    String id = 'outcome-1',
    ChallengeCategory category = ChallengeCategory.reaction,
    double performance = 100,
    BrainProfileOutcomeStatus status = BrainProfileOutcomeStatus.completed,
    bool isEligible = true,
    bool isValid = true,
  }) {
    return BrainProfileOutcome(
      id: id,
      category: category,
      performance: performance,
      status: status,
      isEligible: isEligible,
      isValid: isValid,
    );
  }

  test('maps every challenge category to its explicit skill', () {
    expect(
      brainSkillForChallengeCategory(ChallengeCategory.reaction),
      BrainSkill.reaction,
    );
    expect(
      brainSkillForChallengeCategory(ChallengeCategory.memory),
      BrainSkill.memory,
    );
    expect(
      brainSkillForChallengeCategory(ChallengeCategory.attention),
      BrainSkill.attention,
    );
    expect(
      brainSkillForChallengeCategory(ChallengeCategory.logic),
      BrainSkill.logic,
    );
    expect(
      brainSkillForChallengeCategory(ChallengeCategory.timing),
      BrainSkill.timing,
    );
  });

  test('caps one outcome and tracks confidence and sample count', () {
    final result = updater.apply(const BrainProfile.initial(), outcome());

    expect(result.wasApplied, isTrue);
    expect(result.profile.reaction.value, 58);
    expect(result.profile.reaction.sampleCount, 1);
    expect(result.profile.reaction.confidence, 0.1);
    expect(result.profile.memory.value, 50);
    expect(result.profile.memory.sampleCount, 0);
  });

  test('rejects invalid, abandoned, and ineligible outcomes', () {
    final profile = const BrainProfile.initial();

    expect(
      updater.apply(profile, outcome(isValid: false)).rejection,
      BrainProfileRejection.invalid,
    );
    expect(
      updater
          .apply(profile, outcome(status: BrainProfileOutcomeStatus.abandoned))
          .rejection,
      BrainProfileRejection.abandoned,
    );
    expect(
      updater.apply(profile, outcome(isEligible: false)).rejection,
      BrainProfileRejection.ineligible,
    );
    expect(profile.totalSampleCount, 0);
  });

  test('rejects duplicate and already-applied outcomes', () {
    final initial = const BrainProfile.initial();
    final first = updater.apply(initial, outcome());
    final alreadyApplied = updater.apply(first.profile, outcome());
    final batch = updater.applyAll(initial, [
      outcome(),
      outcome(performance: 0),
    ]);

    expect(alreadyApplied.rejection, BrainProfileRejection.alreadyApplied);
    expect(alreadyApplied.profile.totalSampleCount, 1);
    expect(batch.results[0].wasApplied, isTrue);
    expect(batch.results[1].rejection, BrainProfileRejection.duplicate);
    expect(batch.profile.totalSampleCount, 1);
  });

  test('repeated identical inputs converge predictably', () {
    const convergenceUpdater = BrainProfileUpdater(
      smoothingFactor: 0.5,
      maximumInfluence: 100,
    );
    var profile = const BrainProfile.initial();

    for (var index = 0; index < 4; index++) {
      profile = convergenceUpdater
          .apply(profile, outcome(id: 'outcome-$index', performance: 80))
          .profile;
    }

    expect(profile.reaction.value, 78.125);
    expect(profile.reaction.sampleCount, 4);
    expect(profile.reaction.confidence, 0.4);
  });
}
