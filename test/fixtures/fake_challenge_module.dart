import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenge.dart';

final class FakePlayerAction extends PlayerAction {
  const FakePlayerAction(super.occurredAt);
}

final class FakeChallengeModule {
  FakeChallengeModule() {
    module = ChallengeModule(
      metadata: const ChallengeMetadata(
        id: 'fake_challenge',
        version: '1',
        category: ChallengeCategory.logic,
        minimumDifficulty: MvpDifficulty.easy,
        maximumDifficulty: MvpDifficulty.hard,
        inputModes: {ChallengeInputMode.tap},
        accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
        parameterSchema: {
          'valid': ChallengeParameterBounds(minimum: 0, maximum: 1),
        },
      ),
      validator: const _FakeValidator(),
      evaluator: evaluator,
    );
  }

  final FakeChallengeEvaluator evaluator = FakeChallengeEvaluator();
  late final ChallengeModule module;
}

final class _FakeValidator implements ChallengeValidator {
  const _FakeValidator();

  @override
  bool isValid(RoundPlan plan) => plan.parameters['valid'] == 1;
}

final class FakeChallengeEvaluator implements ChallengeEvaluator {
  int evaluationCount = 0;

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    evaluationCount++;
    return RoundEvaluation(
      outcome: ChallengeOutcome.success,
      metrics: RoundMetrics(
        responseTime: currentRoundTime.difference(action.occurredAt),
        actionCount: 1,
      ),
    );
  }
}
