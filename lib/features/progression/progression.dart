import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mvp_config.dart';

final progressionProvider =
    NotifierProvider<ProgressionController, Progression>(
      ProgressionController.new,
    );

final initialProgressionProvider = Provider<Progression>(
  (ref) => const Progression.initial(),
);

final class Progression {
  Progression({
    required this.totalXp,
    required this.level,
    required Set<String> appliedOutcomeIds,
  }) : _appliedOutcomeIds = Set.unmodifiable(appliedOutcomeIds);

  const Progression.initial()
    : totalXp = 0,
      level = 1,
      _appliedOutcomeIds = const <String>{};

  final int totalXp;
  final int level;
  final Set<String> _appliedOutcomeIds;

  Set<String> get appliedOutcomeIds => _appliedOutcomeIds;

  bool hasAppliedOutcome(String outcomeId) =>
      _appliedOutcomeIds.contains(outcomeId);

  Progression withAward({
    required String outcomeId,
    required int xpDelta,
    required int level,
  }) => Progression(
    totalXp: totalXp + xpDelta,
    level: level,
    appliedOutcomeIds: {..._appliedOutcomeIds, outcomeId},
  );
}

final class ProgressionOutcome {
  const ProgressionOutcome({
    required this.id,
    required this.difficulty,
    required this.isEligible,
  });

  final String id;
  final MvpDifficulty difficulty;
  final bool isEligible;
}

enum ProgressionRejection { ineligible, alreadyApplied }

final class ProgressionUpdateResult {
  const ProgressionUpdateResult.awarded(this.progression, this.xpDelta)
    : rejection = null;

  const ProgressionUpdateResult.rejected(this.progression, this.rejection)
    : xpDelta = 0;

  final Progression progression;
  final int xpDelta;
  final ProgressionRejection? rejection;

  bool get wasApplied => rejection == null;
}

final class ProgressionRules {
  const ProgressionRules();

  int levelForXp({required int totalXp, required MvpProgressionConfig config}) {
    var level = 1;
    for (var index = 1; index < config.levelXpThresholds.length; index++) {
      if (totalXp < config.levelXpThresholds[index]) break;
      level = index + 1;
    }
    return level;
  }

  ProgressionUpdateResult apply({
    required Progression progression,
    required ProgressionOutcome outcome,
    required MvpProgressionConfig config,
  }) {
    final outcomeId = outcome.id.trim();
    if (!outcome.isEligible || outcomeId.isEmpty) {
      return ProgressionUpdateResult.rejected(
        progression,
        ProgressionRejection.ineligible,
      );
    }
    if (progression.hasAppliedOutcome(outcomeId)) {
      return ProgressionUpdateResult.rejected(
        progression,
        ProgressionRejection.alreadyApplied,
      );
    }
    final xpDelta = config.xpForDifficulty(outcome.difficulty);
    final totalXp = progression.totalXp + xpDelta;
    final nextLevel = levelForXp(totalXp: totalXp, config: config);
    return ProgressionUpdateResult.awarded(
      progression.withAward(
        outcomeId: outcomeId,
        xpDelta: xpDelta,
        level: nextLevel < progression.level ? progression.level : nextLevel,
      ),
      xpDelta,
    );
  }
}

final class ProgressionController extends Notifier<Progression> {
  ProgressionController([this._rules = const ProgressionRules()]);

  final ProgressionRules _rules;

  @override
  Progression build() => ref.read(initialProgressionProvider);

  ProgressionUpdateResult applyOutcome({
    required ProgressionOutcome outcome,
    required MvpProgressionConfig config,
  }) {
    final result = _rules.apply(
      progression: state,
      outcome: outcome,
      config: config,
    );
    if (result.wasApplied) state = result.progression;
    return result;
  }
}
