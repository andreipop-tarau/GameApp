import 'package:flutter/material.dart';

import '../../../../core/mvp_config.dart';
import '../../../../core/seeded_random.dart';
import '../../challenge.dart';

const _moduleId = 'selective_attention';
const _moduleVersion = '1';
final DateTime _roundEpoch = DateTime.utc(2000);

const _symbols = [
  'STAR',
  'MOON',
  'LEAF',
  'WAVE',
  'SUN',
  'CLOUD',
  'HEART',
  'BOLT',
];

final class SelectiveAttentionItem {
  const SelectiveAttentionItem({
    required this.id,
    required this.symbol,
    required this.slot,
    required this.left,
    required this.top,
  });

  final int id;
  final String symbol;
  final int slot;
  final double left;
  final double top;

  static const double size = 16;

  bool get isReachable =>
      left >= 0 && top >= 0 && left + size <= 100 && top + size <= 100;

  bool overlaps(SelectiveAttentionItem other) =>
      left < other.left + size &&
      left + size > other.left &&
      top < other.top + size &&
      top + size > other.top;
}

final class SelectiveAttentionLayout {
  const SelectiveAttentionLayout({
    required this.targetSymbol,
    required this.items,
  });

  final String targetSymbol;
  final List<SelectiveAttentionItem> items;

  SelectiveAttentionItem get target =>
      items.singleWhere((item) => item.symbol == targetSymbol);
}

final class SelectiveAttentionPlanGenerator {
  const SelectiveAttentionPlanGenerator();

  RoundPlan generate({
    required MvpModuleConfig config,
    required MvpDifficulty difficulty,
    required int seed,
    required String configVersion,
  }) {
    if (config.id != MvpModuleId.selectiveAttention || !config.enabled) {
      throw ArgumentError.value(
        config,
        'config',
        'Selective Attention must be enabled.',
      );
    }
    final parameters = config.difficultyBands[difficulty];
    if (parameters == null) {
      throw ArgumentError.value(
        difficulty,
        'difficulty',
        'Difficulty is not configured.',
      );
    }
    final plan = RoundPlan(
      moduleId: _moduleId,
      moduleVersion: _moduleVersion,
      configVersion: configVersion,
      seed: seed,
      difficulty: difficulty,
      parameters: Map.unmodifiable(parameters),
    );
    if (!const SelectiveAttentionValidator().isValid(plan)) {
      throw StateError('Generated Selective Attention plan is invalid.');
    }
    return plan;
  }

  SelectiveAttentionLayout layoutFor(RoundPlan plan) {
    final itemCount = plan.parameters['itemCount'];
    if (itemCount == null || itemCount < 2 || itemCount > 20) {
      throw ArgumentError.value(plan, 'plan', 'Item count is invalid.');
    }
    final random = SeededRandom(plan.seed);
    final targetSymbol = _symbols[random.nextInt(_symbols.length)];
    final targetItemId = random.nextInt(itemCount);
    final slots = List.generate(20, (index) => index);
    for (var index = slots.length - 1; index > 0; index--) {
      final swapIndex = random.nextInt(index + 1);
      final slot = slots[index];
      slots[index] = slots[swapIndex];
      slots[swapIndex] = slot;
    }

    final items = List.generate(itemCount, (id) {
      final slot = slots[id];
      final column = slot % 5;
      final row = slot ~/ 5;
      final symbol = id == targetItemId
          ? targetSymbol
          : _distractorSymbol(random, targetSymbol);
      return SelectiveAttentionItem(
        id: id,
        symbol: symbol,
        slot: slot,
        left: column * 20 + 2,
        top: row * 25 + 4,
      );
    });
    return SelectiveAttentionLayout(
      targetSymbol: targetSymbol,
      items: List.unmodifiable(items),
    );
  }

  String _distractorSymbol(SeededRandom random, String targetSymbol) {
    final targetIndex = _symbols.indexOf(targetSymbol);
    final index = random.nextInt(_symbols.length - 1);
    return _symbols[index >= targetIndex ? index + 1 : index];
  }
}

enum SelectiveAttentionActionKind { select, timeout }

final class SelectiveAttentionAction extends PlayerAction {
  SelectiveAttentionAction.select({required this.itemId, required this.elapsed})
    : kind = SelectiveAttentionActionKind.select,
      super(_roundEpoch.add(elapsed));

  SelectiveAttentionAction.timeout({required this.elapsed})
    : kind = SelectiveAttentionActionKind.timeout,
      itemId = null,
      super(_roundEpoch.add(elapsed));

  final SelectiveAttentionActionKind kind;
  final int? itemId;
  final Duration elapsed;
}

final class SelectiveAttentionValidator implements ChallengeValidator {
  const SelectiveAttentionValidator();

  @override
  bool isValid(RoundPlan plan) {
    if (plan.moduleId != _moduleId || plan.moduleVersion != _moduleVersion) {
      return false;
    }
    const bounds = {
      'itemCount': ChallengeParameterBounds(minimum: 2, maximum: 20),
      'similarity': ChallengeParameterBounds(minimum: 0, maximum: 100),
      'motionSpeed': ChallengeParameterBounds(minimum: 0, maximum: 100),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    };
    if (plan.parameters.length != bounds.length ||
        !bounds.entries.every((entry) {
          final value = plan.parameters[entry.key];
          return value != null &&
              value >= entry.value.minimum &&
              value <= entry.value.maximum;
        })) {
      return false;
    }
    final layout = const SelectiveAttentionPlanGenerator().layoutFor(plan);
    return layout.items
                .where((item) => item.symbol == layout.targetSymbol)
                .length ==
            1 &&
        layout.items.every((item) => item.isReachable) &&
        _hasNoOverlaps(layout.items);
  }

  bool _hasNoOverlaps(List<SelectiveAttentionItem> items) {
    for (var first = 0; first < items.length; first++) {
      for (var second = first + 1; second < items.length; second++) {
        if (items[first].overlaps(items[second])) return false;
      }
    }
    return true;
  }
}

final class SelectiveAttentionEvaluator implements ChallengeEvaluator {
  const SelectiveAttentionEvaluator();

  @override
  RoundEvaluation evaluate({
    required RoundPlan plan,
    required PlayerAction action,
    required DateTime currentRoundTime,
  }) {
    if (action is! SelectiveAttentionAction) {
      throw ArgumentError.value(
        action,
        'action',
        'Selective Attention requires its action type.',
      );
    }
    final elapsed = currentRoundTime.difference(_roundEpoch);
    final timeout = Duration(milliseconds: plan.parameters['timeoutMs']!);
    final target = const SelectiveAttentionPlanGenerator()
        .layoutFor(plan)
        .target;
    final success =
        action.kind == SelectiveAttentionActionKind.select &&
        elapsed < timeout &&
        action.itemId == target.id;
    return RoundEvaluation(
      outcome: success ? ChallengeOutcome.success : ChallengeOutcome.failure,
      metrics: RoundMetrics(responseTime: elapsed, actionCount: 1),
    );
  }
}

final class SelectiveAttentionModule {
  const SelectiveAttentionModule();

  static const metadata = ChallengeMetadata(
    id: _moduleId,
    version: _moduleVersion,
    category: ChallengeCategory.attention,
    minimumDifficulty: MvpDifficulty.easy,
    maximumDifficulty: MvpDifficulty.hard,
    inputModes: {ChallengeInputMode.tap},
    accessibilityCapabilities: {AccessibilityCapability.nonColorOnly},
    parameterSchema: {
      'itemCount': ChallengeParameterBounds(minimum: 2, maximum: 20),
      'similarity': ChallengeParameterBounds(minimum: 0, maximum: 100),
      'motionSpeed': ChallengeParameterBounds(minimum: 0, maximum: 100),
      'timeoutMs': ChallengeParameterBounds(minimum: 1000, maximum: 20000),
    },
  );

  ChallengeModule get challengeModule => const ChallengeModule(
    metadata: metadata,
    validator: SelectiveAttentionValidator(),
    evaluator: SelectiveAttentionEvaluator(),
  );
}

final class SelectiveAttentionWidget extends StatefulWidget {
  const SelectiveAttentionWidget({
    required this.plan,
    required this.elapsed,
    required this.onAction,
    super.key,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<SelectiveAttentionAction> onAction;

  @override
  State<SelectiveAttentionWidget> createState() =>
      _SelectiveAttentionWidgetState();
}

final class _SelectiveAttentionWidgetState
    extends State<SelectiveAttentionWidget> {
  bool _resolved = false;

  void _resolve(SelectiveAttentionAction action) {
    if (_resolved) return;
    _resolved = true;
    widget.onAction(action);
  }

  @override
  void didUpdateWidget(covariant SelectiveAttentionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) _resolved = false;
  }

  @override
  Widget build(BuildContext context) {
    final timeout = Duration(
      milliseconds: widget.plan.parameters['timeoutMs']!,
    );
    if (widget.elapsed >= timeout) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resolve(SelectiveAttentionAction.timeout(elapsed: widget.elapsed));
        }
      });
      return const Center(child: Text('Time is up'));
    }
    final layout = const SelectiveAttentionPlanGenerator().layoutFor(
      widget.plan,
    );
    final items = [...layout.items]
      ..sort((first, second) => first.slot.compareTo(second.slot));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Tap the ${layout.targetSymbol}'),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in items)
              Semantics(
                button: true,
                label: 'Attention item ${item.id + 1}: ${item.symbol}',
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: FilledButton(
                    onPressed: () => _resolve(
                      SelectiveAttentionAction.select(
                        itemId: item.id,
                        elapsed: widget.elapsed,
                      ),
                    ),
                    child: Text(item.symbol),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
