import 'challenge.dart';
import 'challenges/reaction_tap/reaction_tap.dart';

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

  ChallengeModule? findById(String id) => _modules[id];

  Iterable<ChallengeModule> get modules => _modules.values;
}
