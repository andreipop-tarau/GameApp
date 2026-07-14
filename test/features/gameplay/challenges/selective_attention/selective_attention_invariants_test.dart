import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';
import 'package:mindtrap_ai/features/gameplay/challenges/selective_attention/selective_attention.dart';

void main() {
  const generator = SelectiveAttentionPlanGenerator();
  const config = MvpModuleConfig(
    id: MvpModuleId.selectiveAttention,
    enabled: true,
    difficultyBands: {
      MvpDifficulty.easy: {
        'itemCount': 4,
        'similarity': 20,
        'motionSpeed': 0,
        'timeoutMs': 7000,
      },
      MvpDifficulty.medium: {
        'itemCount': 9,
        'similarity': 55,
        'motionSpeed': 35,
        'timeoutMs': 5500,
      },
      MvpDifficulty.hard: {
        'itemCount': 15,
        'similarity': 85,
        'motionSpeed': 70,
        'timeoutMs': 4000,
      },
    },
  );

  test('one target, reachable items, and no overlaps hold across seeds', () {
    for (var seed = 0; seed < 200; seed++) {
      final plan = generator.generate(
        config: config,
        difficulty: MvpDifficulty.hard,
        seed: seed,
        configVersion: '1.0.0',
      );
      final layout = generator.layoutFor(plan);

      expect(
        const SelectiveAttentionValidator().isValid(plan),
        isTrue,
        reason: 'seed $seed',
      );
      expect(
        layout.items.where((item) => item.symbol == layout.targetSymbol),
        hasLength(1),
        reason: 'seed $seed',
      );
      expect(
        layout.items.every((item) => item.isReachable),
        isTrue,
        reason: 'seed $seed',
      );
      for (var first = 0; first < layout.items.length; first++) {
        for (var second = first + 1; second < layout.items.length; second++) {
          expect(
            layout.items[first].overlaps(layout.items[second]),
            isFalse,
            reason: 'seed $seed',
          );
        }
      }
    }
  });
}
