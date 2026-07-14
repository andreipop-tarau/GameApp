import '../gameplay/challenge.dart';
import 'brain_profile.dart';

enum BrainProfileOutcomeStatus { completed, abandoned }

final class BrainProfileOutcome {
  const BrainProfileOutcome({
    required this.id,
    required this.category,
    required this.performance,
    required this.status,
    this.isEligible = true,
    this.isValid = true,
  });

  final String id;
  final ChallengeCategory category;
  final double performance;
  final BrainProfileOutcomeStatus status;
  final bool isEligible;
  final bool isValid;
}

enum BrainProfileRejection {
  invalid,
  abandoned,
  ineligible,
  duplicate,
  alreadyApplied,
}

final class BrainProfileUpdateResult {
  const BrainProfileUpdateResult.applied(this.profile) : rejection = null;

  const BrainProfileUpdateResult.rejected(this.profile, this.rejection);

  final BrainProfile profile;
  final BrainProfileRejection? rejection;

  bool get wasApplied => rejection == null;
}

final class BrainProfileBatchUpdateResult {
  const BrainProfileBatchUpdateResult({
    required this.profile,
    required this.results,
  });

  final BrainProfile profile;
  final List<BrainProfileUpdateResult> results;
}

BrainSkill brainSkillForChallengeCategory(ChallengeCategory category) {
  return switch (category) {
    ChallengeCategory.reaction => BrainSkill.reaction,
    ChallengeCategory.memory => BrainSkill.memory,
    ChallengeCategory.attention => BrainSkill.attention,
    ChallengeCategory.logic => BrainSkill.logic,
    ChallengeCategory.timing => BrainSkill.timing,
  };
}

final class BrainProfileUpdater {
  const BrainProfileUpdater({
    this.smoothingFactor = 0.20,
    this.maximumInfluence = 8,
    this.samplesForFullConfidence = 10,
  }) : assert(smoothingFactor > 0 && smoothingFactor <= 1),
       assert(maximumInfluence > 0 && maximumInfluence <= 100),
       assert(samplesForFullConfidence > 0);

  final double smoothingFactor;
  final double maximumInfluence;
  final int samplesForFullConfidence;

  BrainProfileUpdateResult apply(
    BrainProfile profile,
    BrainProfileOutcome outcome,
  ) {
    final outcomeId = outcome.id.trim();
    if (!outcome.isValid ||
        outcomeId.isEmpty ||
        !outcome.performance.isFinite ||
        outcome.performance < 0 ||
        outcome.performance > 100) {
      return BrainProfileUpdateResult.rejected(
        profile,
        BrainProfileRejection.invalid,
      );
    }
    if (outcome.status == BrainProfileOutcomeStatus.abandoned) {
      return BrainProfileUpdateResult.rejected(
        profile,
        BrainProfileRejection.abandoned,
      );
    }
    if (!outcome.isEligible) {
      return BrainProfileUpdateResult.rejected(
        profile,
        BrainProfileRejection.ineligible,
      );
    }
    if (profile.hasAppliedOutcome(outcomeId)) {
      return BrainProfileUpdateResult.rejected(
        profile,
        BrainProfileRejection.alreadyApplied,
      );
    }

    final skill = brainSkillForChallengeCategory(outcome.category);
    final current = profile.estimateFor(skill);
    final smoothedDelta =
        (outcome.performance - current.value) * smoothingFactor;
    final boundedDelta = smoothedDelta.clamp(
      -maximumInfluence,
      maximumInfluence,
    );
    final nextSampleCount = current.sampleCount + 1;
    final nextEstimate = BrainSkillEstimate(
      value: (current.value + boundedDelta).clamp(0, 100).toDouble(),
      confidence: (nextSampleCount / samplesForFullConfidence)
          .clamp(0, 1)
          .toDouble(),
      sampleCount: nextSampleCount,
    );

    return BrainProfileUpdateResult.applied(
      profile.withAppliedOutcome(
        outcomeId: outcomeId,
        skill: skill,
        estimate: nextEstimate,
      ),
    );
  }

  BrainProfileBatchUpdateResult applyAll(
    BrainProfile profile,
    Iterable<BrainProfileOutcome> outcomes,
  ) {
    var current = profile;
    final seenOutcomeIds = <String>{};
    final results = <BrainProfileUpdateResult>[];

    for (final outcome in outcomes) {
      final outcomeId = outcome.id.trim();
      if (outcomeId.isNotEmpty && !seenOutcomeIds.add(outcomeId)) {
        results.add(
          BrainProfileUpdateResult.rejected(
            current,
            BrainProfileRejection.duplicate,
          ),
        );
        continue;
      }

      final result = apply(current, outcome);
      results.add(result);
      if (result.wasApplied) current = result.profile;
    }

    return BrainProfileBatchUpdateResult(
      profile: current,
      results: List.unmodifiable(results),
    );
  }
}
