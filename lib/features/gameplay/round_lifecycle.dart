import 'challenge.dart';

enum RoundLifecycleState { created, briefing, active, resolved }

final class RoundLifecycle {
  RoundLifecycle({required this.plan, required ChallengeModule module})
    : _module = module {
    if (module.metadata.id != plan.moduleId ||
        module.metadata.version != plan.moduleVersion ||
        !module.validator.isValid(plan)) {
      throw ArgumentError.value(
        plan,
        'plan',
        'Round plan is invalid for module.',
      );
    }
  }

  final RoundPlan plan;
  final ChallengeModule _module;
  RoundLifecycleState _state = RoundLifecycleState.created;
  RoundEvaluation? _evaluation;

  RoundLifecycleState get state => _state;

  RoundEvaluation? get evaluation => _evaluation;

  void beginBriefing() {
    if (_state != RoundLifecycleState.created) {
      throw StateError('A round can only enter briefing when created.');
    }
    _state = RoundLifecycleState.briefing;
  }

  void beginActive() {
    if (_state != RoundLifecycleState.briefing) {
      throw StateError('A round can only become active after briefing.');
    }
    _state = RoundLifecycleState.active;
  }

  RoundEvaluation resolve(PlayerAction action, DateTime currentRoundTime) {
    final existingEvaluation = _evaluation;
    if (existingEvaluation != null) return existingEvaluation;
    if (_state != RoundLifecycleState.active) {
      throw StateError('Only an active round can be resolved.');
    }

    final resolved = _module.evaluator.evaluate(
      plan: plan,
      action: action,
      currentRoundTime: currentRoundTime,
    );
    _evaluation = resolved;
    _state = RoundLifecycleState.resolved;
    return resolved;
  }
}
