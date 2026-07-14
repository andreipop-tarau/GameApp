import '../../core/mvp_config.dart';
import '../brain_profile/brain_profile.dart';

final class DifficultyPolicy {
  const DifficultyPolicy();

  MvpDifficulty select({
    required BrainSkillEstimate skill,
    required Iterable<MvpDifficulty> allowedDifficulties,
    required MvpDifficulty? previousDifficulty,
    required int consecutiveFailures,
    required bool? lastRoundSucceeded,
  }) {
    final allowed = allowedDifficulties.toSet().toList()
      ..sort((left, right) => left.index.compareTo(right.index));
    if (allowed.isEmpty) {
      throw ArgumentError.value(
        allowedDifficulties,
        'allowedDifficulties',
        'At least one difficulty is required.',
      );
    }

    final current =
        previousDifficulty != null && allowed.contains(previousDifficulty)
        ? previousDifficulty
        : allowed.first;
    if (consecutiveFailures >= 3 || lastRoundSucceeded == false) {
      return _moveOneStep(current, -1, allowed);
    }

    final desiredIndex = skill.confidence < 0.3
        ? allowed.first.index
        : skill.value >= 80
        ? MvpDifficulty.hard.index
        : skill.value >= 55
        ? MvpDifficulty.medium.index
        : MvpDifficulty.easy.index;
    final boundedTarget = desiredIndex.clamp(
      allowed.first.index,
      allowed.last.index,
    );
    if (boundedTarget == current.index) return current;
    return _moveOneStep(
      current,
      boundedTarget > current.index ? 1 : -1,
      allowed,
    );
  }

  MvpDifficulty _moveOneStep(
    MvpDifficulty current,
    int direction,
    List<MvpDifficulty> allowed,
  ) {
    final nextIndex = current.index + direction;
    if (nextIndex < 0 || nextIndex >= MvpDifficulty.values.length) {
      return current;
    }
    final next = MvpDifficulty.values[nextIndex];
    return allowed.contains(next) ? next : current;
  }
}
