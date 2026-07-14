import '../../core/mvp_config.dart';
import '../../core/seeded_random.dart';
import '../brain_profile/brain_profile.dart';
import 'difficulty_policy.dart';

enum AiDirectorSelectionReason {
  coldStartRotation,
  repeatAvoidance,
  recovery,
  profileFit,
  onlyCandidate,
}

extension AiDirectorSelectionReasonCode on AiDirectorSelectionReason {
  String get code => switch (this) {
    AiDirectorSelectionReason.coldStartRotation => 'cold_start_rotation',
    AiDirectorSelectionReason.repeatAvoidance => 'repeat_avoidance',
    AiDirectorSelectionReason.recovery => 'recovery',
    AiDirectorSelectionReason.profileFit => 'profile_fit',
    AiDirectorSelectionReason.onlyCandidate => 'only_candidate',
  };
}

final class AiDirectorRoundHistory {
  const AiDirectorRoundHistory({
    required this.moduleId,
    required this.difficulty,
    this.outcomeId,
    this.wasSuccessful,
  });

  final MvpModuleId moduleId;
  final MvpDifficulty difficulty;
  final String? outcomeId;
  final bool? wasSuccessful;

  AiDirectorRoundHistory withOutcome(bool succeeded) {
    return AiDirectorRoundHistory(
      moduleId: moduleId,
      difficulty: difficulty,
      outcomeId: outcomeId,
      wasSuccessful: succeeded,
    );
  }
}

final class AiDirectorRequest {
  AiDirectorRequest({
    required this.config,
    required this.profile,
    required Iterable<AiDirectorRoundHistory> recentHistory,
    required this.consecutiveFailures,
    required this.seed,
  }) : recentHistory = List.unmodifiable(recentHistory);

  final MvpConfig config;
  final BrainProfile profile;
  final List<AiDirectorRoundHistory> recentHistory;
  final int consecutiveFailures;
  final int seed;
}

final class AiDirectorSelection {
  const AiDirectorSelection({
    required this.module,
    required this.difficulty,
    required this.reason,
    required this.policyVersion,
  });

  final MvpModuleConfig module;
  final MvpDifficulty difficulty;
  final AiDirectorSelectionReason reason;
  final String policyVersion;
}

final class AiDirector {
  const AiDirector({this.difficultyPolicy = const DifficultyPolicy()});

  static const policyVersion = 'ai-director-v1';
  static const _categoryRotationWeight = 100;
  static const _moduleRotationWeight = 20;
  static const _confidenceNeedWeight = 20;
  static const _recentPenalties = [60, 30, 10];

  final DifficultyPolicy difficultyPolicy;

  AiDirectorSelection select(AiDirectorRequest request) {
    var candidates = _eligibleCandidates(request.config);
    if (candidates.isEmpty) {
      throw StateError('No eligible AI Director candidates.');
    }
    final recovery = request.consecutiveFailures >= 3;
    if (recovery && request.recentHistory.isNotEmpty) {
      final previousIndex = request.recentHistory.last.difficulty.index;
      if (previousIndex > MvpDifficulty.easy.index) {
        final easierDifficulty = MvpDifficulty.values[previousIndex - 1];
        final easierCandidates = candidates
            .where(
              (candidate) =>
                  candidate.difficultyBands.containsKey(easierDifficulty),
            )
            .toList(growable: false);
        if (easierCandidates.isNotEmpty) candidates = easierCandidates;
      }
    }

    var pool = candidates;
    var avoidedRecentRepeat = false;
    if (candidates.length > 1 && request.recentHistory.isNotEmpty) {
      final lastModule = request.recentHistory.last.moduleId;
      final alternatives = candidates
          .where((candidate) => candidate.id != lastModule)
          .toList(growable: false);
      if (alternatives.isNotEmpty) {
        pool = alternatives;
        avoidedRecentRepeat = true;
      }
    }

    final scores = <MvpModuleConfig, int>{
      for (final candidate in pool)
        candidate: _scoreCandidate(candidate, request),
    };
    final highestScore = scores.values.reduce(
      (highest, score) => score > highest ? score : highest,
    );
    final tied =
        scores.entries
            .where((entry) => entry.value == highestScore)
            .map((entry) => entry.key)
            .toList()
          ..sort((left, right) => left.id.value.compareTo(right.id.value));
    final selected = tied[SeededRandom(request.seed).nextInt(tied.length)];
    final skill = request.profile.estimateFor(_skillForModule(selected.id));
    final previousDifficulty = request.recentHistory.isEmpty
        ? null
        : request.recentHistory.last.difficulty;
    final difficulty = difficultyPolicy.select(
      skill: skill,
      allowedDifficulties: selected.difficultyBands.keys,
      previousDifficulty: previousDifficulty,
      consecutiveFailures: request.consecutiveFailures,
      lastRoundSucceeded: _lastCompletedOutcome(request.recentHistory),
    );

    return AiDirectorSelection(
      module: selected,
      difficulty: difficulty,
      reason: recovery
          ? AiDirectorSelectionReason.recovery
          : candidates.length == 1
          ? AiDirectorSelectionReason.onlyCandidate
          : request.profile.hasSparseData
          ? AiDirectorSelectionReason.coldStartRotation
          : avoidedRecentRepeat
          ? AiDirectorSelectionReason.repeatAvoidance
          : AiDirectorSelectionReason.profileFit,
      policyVersion: policyVersion,
    );
  }

  List<MvpModuleConfig> _eligibleCandidates(MvpConfig config) {
    final candidates = <MvpModuleId, MvpModuleConfig>{};
    for (final module in config.modules) {
      if (!module.enabled || module.difficultyBands.isEmpty) continue;
      candidates.putIfAbsent(module.id, () => module);
    }
    return candidates.values.toList(growable: false);
  }

  int _scoreCandidate(MvpModuleConfig candidate, AiDirectorRequest request) {
    final skillId = _skillForModule(candidate.id);
    final estimate = request.profile.estimateFor(skillId);
    final categoryPlayCount = request.recentHistory
        .where((round) => _skillForModule(round.moduleId) == skillId)
        .length;
    final modulePlayCount = request.recentHistory
        .where((round) => round.moduleId == candidate.id)
        .length;
    var score =
        -(categoryPlayCount * _categoryRotationWeight) -
        (modulePlayCount * _moduleRotationWeight) +
        ((1 - estimate.confidence) * _confidenceNeedWeight).round();

    var recentIndex = 0;
    for (final round in request.recentHistory.reversed.take(3)) {
      if (round.moduleId == candidate.id) {
        score -= _recentPenalties[recentIndex];
      }
      recentIndex++;
    }
    if (request.consecutiveFailures >= 3) {
      score += estimate.value.round();
    }
    return score;
  }

  bool? _lastCompletedOutcome(List<AiDirectorRoundHistory> history) {
    for (final round in history.reversed) {
      if (round.wasSuccessful != null) return round.wasSuccessful;
    }
    return null;
  }

  BrainSkill _skillForModule(MvpModuleId moduleId) => switch (moduleId) {
    MvpModuleId.reactionTap => BrainSkill.reaction,
    MvpModuleId.sequenceMemory => BrainSkill.memory,
    MvpModuleId.selectiveAttention => BrainSkill.attention,
    MvpModuleId.timingStop => BrainSkill.timing,
    MvpModuleId.logicChoice => BrainSkill.logic,
  };
}
