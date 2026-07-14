import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mvp_config.dart';
import '../../core/seeded_random.dart';
import 'challenge.dart';
import 'challenge_catalog.dart';
import 'challenges/logic_choice/logic_choice.dart';
import 'challenges/reaction_tap/reaction_tap.dart';
import 'challenges/selective_attention/selective_attention.dart';
import 'challenges/sequence_memory/sequence_memory.dart';
import 'challenges/timing_stop/timing_stop.dart';
import 'round_lifecycle.dart';

final gameSessionControllerProvider =
    NotifierProvider<GameSessionController, GameSessionState>(
      GameSessionController.new,
    );

typedef GameConfigLoader = Future<MvpConfig> Function();

enum GameSessionStatus { idle, loading, active, result, failure }

final class GameSessionState {
  const GameSessionState._({
    required this.status,
    this.plan,
    this.module,
    this.evaluation,
  });

  const GameSessionState.idle() : this._(status: GameSessionStatus.idle);

  const GameSessionState.loading() : this._(status: GameSessionStatus.loading);

  const GameSessionState.active({
    required RoundPlan plan,
    required ChallengeModule module,
  }) : this._(status: GameSessionStatus.active, plan: plan, module: module);

  const GameSessionState.result({
    required RoundPlan plan,
    required ChallengeModule module,
    required RoundEvaluation evaluation,
  }) : this._(
         status: GameSessionStatus.result,
         plan: plan,
         module: module,
         evaluation: evaluation,
       );

  const GameSessionState.failure() : this._(status: GameSessionStatus.failure);

  final GameSessionStatus status;
  final RoundPlan? plan;
  final ChallengeModule? module;
  final RoundEvaluation? evaluation;
}

final class GameSessionController extends Notifier<GameSessionState> {
  GameSessionController({GameConfigLoader? configLoader})
    : _configLoader = configLoader ?? _loadBundledConfig;

  final ChallengeCatalog _catalog = ChallengeCatalog.mvp();
  final GameConfigLoader _configLoader;
  RoundLifecycle? _lifecycle;
  MvpConfig? _config;
  int _roundNumber = 0;
  static const _sessionSeed = 1009;

  @override
  GameSessionState build() => const GameSessionState.idle();

  Future<void> startRound() async {
    if (state.status == GameSessionStatus.loading) return;
    state = const GameSessionState.loading();

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final round = await _generateRound();
        _lifecycle = RoundLifecycle(plan: round.plan, module: round.module)
          ..beginBriefing()
          ..beginActive();
        _roundNumber++;
        state = GameSessionState.active(plan: round.plan, module: round.module);
        return;
      } catch (_) {
        _lifecycle = null;
      }
    }

    state = const GameSessionState.failure();
  }

  void submit(PlayerAction action, Duration elapsed) {
    if (state.status != GameSessionStatus.active) return;
    final lifecycle = _lifecycle;
    if (lifecycle == null) return;

    final evaluation = lifecycle.resolve(
      action,
      DateTime.utc(2000).add(elapsed),
    );
    state = GameSessionState.result(
      plan: lifecycle.plan,
      module: state.module!,
      evaluation: evaluation,
    );
  }

  void exit() {
    _lifecycle = null;
    state = const GameSessionState.idle();
  }

  Future<_GeneratedRound> _generateRound() async {
    final config = _config ??= await _configLoader();
    final enabled = config.modules.where((module) => module.enabled).toList();
    if (enabled.isEmpty) throw StateError('No challenge modules are enabled.');

    final rotationStart = SeededRandom(_sessionSeed).nextInt(enabled.length);
    final moduleConfig =
        enabled[(rotationStart + _roundNumber) % enabled.length];
    final module = _catalog.findById(moduleConfig.id.value);
    if (module == null) {
      throw StateError('Enabled module is missing from the challenge catalog.');
    }

    final seed = _sessionSeed + _roundNumber;
    final plan = switch (moduleConfig.id) {
      MvpModuleId.reactionTap => const ReactionTapPlanGenerator().generate(
        config: moduleConfig,
        difficulty: MvpDifficulty.easy,
        seed: seed,
        configVersion: config.contentVersion,
      ),
      MvpModuleId.sequenceMemory =>
        const SequenceMemoryPlanGenerator().generate(
          config: moduleConfig,
          difficulty: MvpDifficulty.easy,
          seed: seed,
          configVersion: config.contentVersion,
        ),
      MvpModuleId.selectiveAttention =>
        const SelectiveAttentionPlanGenerator().generate(
          config: moduleConfig,
          difficulty: MvpDifficulty.easy,
          seed: seed,
          configVersion: config.contentVersion,
        ),
      MvpModuleId.timingStop => const TimingStopPlanGenerator().generate(
        config: moduleConfig,
        difficulty: MvpDifficulty.easy,
        seed: seed,
        configVersion: config.contentVersion,
      ),
      MvpModuleId.logicChoice => const LogicChoicePlanGenerator().generate(
        config: moduleConfig,
        difficulty: MvpDifficulty.easy,
        seed: seed,
        configVersion: config.contentVersion,
      ),
    };
    return _GeneratedRound(plan: plan, module: module);
  }

  static Future<MvpConfig> _loadBundledConfig() async {
    final source = await rootBundle.loadString(mvpChallengesAssetPath);
    final result = parseMvpConfig(source);
    if (result case MvpConfigLoaded(:final config)) return config;
    throw StateError('Bundled challenge configuration is invalid.');
  }
}

final class _GeneratedRound {
  const _GeneratedRound({required this.plan, required this.module});

  final RoundPlan plan;
  final ChallengeModule module;
}
