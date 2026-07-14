import 'challenge.dart';
import 'challenges/reaction_tap/reaction_tap.dart';
import 'challenges/selective_attention/selective_attention.dart';
import 'challenges/sequence_memory/sequence_memory.dart';
import 'challenges/timing_stop/timing_stop.dart';

final class ChallengeCatalog {
  ChallengeCatalog(Iterable<ChallengeModule> modules)
    : _modules = {for (final module in modules) module.metadata.id: module} {
    if (_modules.length != modules.length) {
      throw ArgumentError('Challenge module IDs must be unique.');
    }
  }

  final Map<String, ChallengeModule> _modules;

  factory ChallengeCatalog.reactionTap() =>
      ChallengeCatalog([const ReactionTapModule().challengeModule]);

  factory ChallengeCatalog.sequenceMemory() =>
      ChallengeCatalog([const SequenceMemoryModule().challengeModule]);

  factory ChallengeCatalog.selectiveAttention() =>
      ChallengeCatalog([const SelectiveAttentionModule().challengeModule]);

  factory ChallengeCatalog.timingStop() =>
      ChallengeCatalog([const TimingStopModule().challengeModule]);

  ChallengeModule? findById(String id) => _modules[id];

  Iterable<ChallengeModule> get modules => _modules.values;
}
