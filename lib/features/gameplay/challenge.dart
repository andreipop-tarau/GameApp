import '../../core/mvp_config.dart';

enum ChallengeCategory { reaction, memory, attention, timing, logic }

enum ChallengeInputMode { tap, sequence, choice }

enum AccessibilityCapability { nonColorOnly }

final class ChallengeParameterBounds {
  const ChallengeParameterBounds({
    required this.minimum,
    required this.maximum,
  });

  final int minimum;
  final int maximum;
}

final class ChallengeMetadata {
  const ChallengeMetadata({
    required this.id,
    required this.version,
    required this.category,
    required this.minimumDifficulty,
    required this.maximumDifficulty,
    required this.inputModes,
    required this.accessibilityCapabilities,
    required this.parameterSchema,
  });

  final String id;
  final String version;
  final ChallengeCategory category;
  final MvpDifficulty minimumDifficulty;
  final MvpDifficulty maximumDifficulty;
  final Set<ChallengeInputMode> inputModes;
  final Set<AccessibilityCapability> accessibilityCapabilities;
  final Map<String, ChallengeParameterBounds> parameterSchema;
}

final class RoundPlan {
  const RoundPlan({
    required this.moduleId,
    required this.moduleVersion,
    required this.configVersion,
    required this.seed,
    required this.difficulty,
    required this.parameters,
  });

  final String moduleId;
  final String moduleVersion;
  final String configVersion;
  final int seed;
  final MvpDifficulty difficulty;
  final Map<String, int> parameters;
}

abstract class PlayerAction {
  const PlayerAction(this.occurredAt);

  final DateTime occurredAt;
}

enum ChallengeOutcome { success, failure }

final class RoundMetrics {
  const RoundMetrics({required this.responseTime, required this.actionCount});

  final Duration responseTime;
  final int actionCount;
}

final class RoundEvaluation {
  const RoundEvaluation({required this.outcome, required this.metrics});

  final ChallengeOutcome outcome;
  final RoundMetrics metrics;
}

abstract interface class ChallengeValidator {
  bool isValid(RoundPlan plan);
}

abstract interface class ChallengeEvaluator {
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  });
}

final class ChallengeModule {
  const ChallengeModule({
    required this.metadata,
    required this.validator,
    required this.evaluator,
  });

  final ChallengeMetadata metadata;
  final ChallengeValidator validator;
  final ChallengeEvaluator evaluator;
}
