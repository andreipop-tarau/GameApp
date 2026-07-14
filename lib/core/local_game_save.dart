import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'mvp_config.dart';
import '../features/brain_profile/brain_profile.dart';
import '../features/progression/progression.dart';

const localGameSavePreferenceKey = 'local_game_save';

enum LocalGameSaveLoadStatus { loaded, empty, corrupt, unsupported }

final class LocalGameSaveLoadResult {
  const LocalGameSaveLoadResult._(this.status, this.save);

  const LocalGameSaveLoadResult.loaded(LocalGameSave save)
    : this._(LocalGameSaveLoadStatus.loaded, save);

  const LocalGameSaveLoadResult.empty()
    : this._(LocalGameSaveLoadStatus.empty, const LocalGameSave.empty());

  const LocalGameSaveLoadResult.corrupt()
    : this._(LocalGameSaveLoadStatus.corrupt, const LocalGameSave.empty());

  const LocalGameSaveLoadResult.unsupported()
    : this._(LocalGameSaveLoadStatus.unsupported, const LocalGameSave.empty());

  final LocalGameSaveLoadStatus status;
  final LocalGameSave save;
}

enum LocalGameSaveWriteStatus { saved, failed }

final class LocalGameSaveWriteResult {
  const LocalGameSaveWriteResult._(this.status);

  const LocalGameSaveWriteResult.saved()
    : this._(LocalGameSaveWriteStatus.saved);

  const LocalGameSaveWriteResult.failed()
    : this._(LocalGameSaveWriteStatus.failed);

  final LocalGameSaveWriteStatus status;
}

final class LocalRoundOutcome {
  const LocalRoundOutcome({
    required this.id,
    required this.moduleId,
    required this.difficulty,
    required this.wasSuccessful,
  });

  final String id;
  final String moduleId;
  final String difficulty;
  final bool wasSuccessful;

  Map<String, Object> toJson() => {
    'id': id,
    'moduleId': moduleId,
    'difficulty': difficulty,
    'wasSuccessful': wasSuccessful,
  };
}

final class LocalGameSave {
  const LocalGameSave({
    required this.brainProfile,
    required this.progression,
    required this.recentOutcomes,
  }) : assert(recentOutcomes.length <= historyLimit);

  const LocalGameSave.empty()
    : brainProfile = const BrainProfile.initial(),
      progression = const Progression.initial(),
      recentOutcomes = const [];

  static const schemaVersion = 1;
  static const historyLimit = 10;

  final BrainProfile brainProfile;
  final Progression progression;
  final List<LocalRoundOutcome> recentOutcomes;

  Map<String, Object> toJson() => {
    'schemaVersion': schemaVersion,
    'brainProfile': _profileToJson(brainProfile),
    'progression': _progressionToJson(progression),
    'recentOutcomes': recentOutcomes
        .map((outcome) => outcome.toJson())
        .toList(),
  };

  static LocalGameSaveLoadResult decode(String source) {
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) {
        return const LocalGameSaveLoadResult.corrupt();
      }
      final version = decoded['schemaVersion'];
      if (version is! int) return const LocalGameSaveLoadResult.corrupt();
      if (version != schemaVersion) {
        return const LocalGameSaveLoadResult.unsupported();
      }
      final profile = _profileFromJson(decoded['brainProfile']);
      final progression = _progressionFromJson(decoded['progression']);
      final outcomes = _outcomesFromJson(decoded['recentOutcomes']);
      if (profile == null || progression == null || outcomes == null) {
        return const LocalGameSaveLoadResult.corrupt();
      }
      return LocalGameSaveLoadResult.loaded(
        LocalGameSave(
          brainProfile: profile,
          progression: progression,
          recentOutcomes: outcomes,
        ),
      );
    } on FormatException {
      return const LocalGameSaveLoadResult.corrupt();
    } on TypeError {
      return const LocalGameSaveLoadResult.corrupt();
    }
  }
}

Map<String, Object> _progressionToJson(Progression progression) => {
  'totalXp': progression.totalXp,
  'level': progression.level,
  'appliedOutcomeIds': progression.appliedOutcomeIds.toList(),
};

Progression? _progressionFromJson(Object? value) {
  if (value == null) return const Progression.initial();
  if (value is! Map<String, dynamic>) return null;
  final totalXp = value['totalXp'];
  final level = value['level'];
  final ids = value['appliedOutcomeIds'];
  if (totalXp is! int ||
      totalXp < 0 ||
      level is! int ||
      level < 1 ||
      ids is! List) {
    return null;
  }
  final appliedOutcomeIds = <String>{};
  for (final id in ids) {
    if (id is! String || id.trim().isEmpty || !appliedOutcomeIds.add(id)) {
      return null;
    }
  }
  return Progression(
    totalXp: totalXp,
    level: level,
    appliedOutcomeIds: appliedOutcomeIds,
  );
}

final class LocalGameSaveStore {
  const LocalGameSaveStore(this._preferences);

  final SharedPreferences _preferences;

  Future<LocalGameSaveLoadResult> load() async {
    try {
      final source = _preferences.getString(localGameSavePreferenceKey);
      if (source == null || source.trim().isEmpty) {
        return const LocalGameSaveLoadResult.empty();
      }
      return LocalGameSave.decode(source);
    } on TypeError {
      return const LocalGameSaveLoadResult.corrupt();
    }
  }

  Future<LocalGameSaveWriteResult> save(LocalGameSave save) async {
    try {
      final didSave = await _preferences.setString(
        localGameSavePreferenceKey,
        jsonEncode(save.toJson()),
      );
      return didSave
          ? const LocalGameSaveWriteResult.saved()
          : const LocalGameSaveWriteResult.failed();
    } catch (_) {
      return const LocalGameSaveWriteResult.failed();
    }
  }
}

Map<String, Object> _profileToJson(BrainProfile profile) => {
  'reaction': _estimateToJson(profile.reaction),
  'memory': _estimateToJson(profile.memory),
  'attention': _estimateToJson(profile.attention),
  'logic': _estimateToJson(profile.logic),
  'timing': _estimateToJson(profile.timing),
  'appliedOutcomeIds': profile.appliedOutcomeIds.toList(),
};

Map<String, Object> _estimateToJson(BrainSkillEstimate estimate) => {
  'value': estimate.value,
  'confidence': estimate.confidence,
  'sampleCount': estimate.sampleCount,
};

BrainProfile? _profileFromJson(Object? value) {
  if (value is! Map<String, dynamic>) return null;
  final reaction = _estimateFromJson(value['reaction']);
  final memory = _estimateFromJson(value['memory']);
  final attention = _estimateFromJson(value['attention']);
  final logic = _estimateFromJson(value['logic']);
  final timing = _estimateFromJson(value['timing']);
  final ids = value['appliedOutcomeIds'];
  if (reaction == null ||
      memory == null ||
      attention == null ||
      logic == null ||
      timing == null ||
      ids is! List) {
    return null;
  }
  final appliedOutcomeIds = <String>{};
  for (final id in ids) {
    if (id is! String || id.trim().isEmpty || !appliedOutcomeIds.add(id)) {
      return null;
    }
  }
  return BrainProfile.restored(
    reaction: reaction,
    memory: memory,
    attention: attention,
    logic: logic,
    timing: timing,
    appliedOutcomeIds: appliedOutcomeIds,
  );
}

BrainSkillEstimate? _estimateFromJson(Object? value) {
  if (value is! Map<String, dynamic>) return null;
  final score = value['value'];
  final confidence = value['confidence'];
  final sampleCount = value['sampleCount'];
  if (score is! num ||
      confidence is! num ||
      sampleCount is! int ||
      !score.isFinite ||
      !confidence.isFinite ||
      score < 0 ||
      score > 100 ||
      confidence < 0 ||
      confidence > 1 ||
      sampleCount < 0) {
    return null;
  }
  return BrainSkillEstimate(
    value: score.toDouble(),
    confidence: confidence.toDouble(),
    sampleCount: sampleCount,
  );
}

List<LocalRoundOutcome>? _outcomesFromJson(Object? value) {
  if (value is! List) return null;
  final outcomes = <LocalRoundOutcome>[];
  final ids = <String>{};
  for (final item in value) {
    if (item is! Map<String, dynamic>) return null;
    final id = item['id'];
    final moduleId = item['moduleId'];
    final difficulty = item['difficulty'];
    final wasSuccessful = item['wasSuccessful'];
    if (id is! String ||
        id.trim().isEmpty ||
        !ids.add(id) ||
        moduleId is! String ||
        difficulty is! String ||
        wasSuccessful is! bool ||
        MvpModuleId.fromValue(moduleId) == null ||
        !MvpDifficulty.values.any((value) => value.name == difficulty)) {
      return null;
    }
    outcomes.add(
      LocalRoundOutcome(
        id: id,
        moduleId: moduleId,
        difficulty: difficulty,
        wasSuccessful: wasSuccessful,
      ),
    );
  }
  return outcomes.length <= LocalGameSave.historyLimit ? outcomes : null;
}
