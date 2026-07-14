import 'dart:convert';

const mvpChallengesAssetPath = 'assets/config/mvp_challenges.json';

final class MvpConfig {
  const MvpConfig({
    required this.schemaVersion,
    required this.contentVersion,
    required this.modules,
  });

  final int schemaVersion;
  final String contentVersion;
  final List<MvpModuleConfig> modules;
}

final class MvpModuleConfig {
  const MvpModuleConfig({
    required this.id,
    required this.enabled,
    required this.difficultyBands,
  });

  final MvpModuleId id;
  final bool enabled;
  final Map<MvpDifficulty, Map<String, int>> difficultyBands;
}

enum MvpModuleId {
  reactionTap('reaction_tap'),
  sequenceMemory('sequence_memory'),
  selectiveAttention('selective_attention'),
  timingStop('timing_stop'),
  logicChoice('logic_choice');

  const MvpModuleId(this.value);

  final String value;

  static MvpModuleId? fromValue(String value) {
    for (final module in values) {
      if (module.value == value) return module;
    }
    return null;
  }
}

enum MvpDifficulty {
  easy('easy'),
  medium('medium'),
  hard('hard');

  const MvpDifficulty(this.value);

  final String value;
}

sealed class MvpConfigParseResult {
  const MvpConfigParseResult();
}

final class MvpConfigLoaded extends MvpConfigParseResult {
  const MvpConfigLoaded(this.config);

  final MvpConfig config;
}

final class MvpConfigFailure extends MvpConfigParseResult {
  const MvpConfigFailure(this.reason);

  final MvpConfigFailureReason reason;
}

enum MvpConfigFailureReason { malformed, unsupportedSchema, invalidParameters }

MvpConfigParseResult parseMvpConfig(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      return const MvpConfigFailure(MvpConfigFailureReason.malformed);
    }

    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion is! int) {
      return const MvpConfigFailure(MvpConfigFailureReason.malformed);
    }
    if (schemaVersion != 1) {
      return const MvpConfigFailure(MvpConfigFailureReason.unsupportedSchema);
    }

    final contentVersion = decoded['contentVersion'];
    final modulesValue = decoded['modules'];
    if (contentVersion is! String ||
        contentVersion.isEmpty ||
        modulesValue is! List) {
      return const MvpConfigFailure(MvpConfigFailureReason.malformed);
    }

    final modules = <MvpModuleConfig>[];
    final moduleIds = <MvpModuleId>{};
    for (final value in modulesValue) {
      final module = _parseModule(value);
      if (module == null || !moduleIds.add(module.id)) {
        return const MvpConfigFailure(MvpConfigFailureReason.invalidParameters);
      }
      modules.add(module);
    }

    if (modules.length != MvpModuleId.values.length ||
        moduleIds.length != MvpModuleId.values.length) {
      return const MvpConfigFailure(MvpConfigFailureReason.invalidParameters);
    }

    return MvpConfigLoaded(
      MvpConfig(
        schemaVersion: schemaVersion,
        contentVersion: contentVersion,
        modules: List.unmodifiable(modules),
      ),
    );
  } on FormatException {
    return const MvpConfigFailure(MvpConfigFailureReason.malformed);
  }
}

MvpModuleConfig? _parseModule(Object? value) {
  if (value is! Map<String, dynamic>) return null;

  final idValue = value['id'];
  final enabled = value['enabled'];
  final bandsValue = value['difficultyBands'];
  if (idValue is! String ||
      enabled is! bool ||
      bandsValue is! Map<String, dynamic>) {
    return null;
  }

  final id = MvpModuleId.fromValue(idValue);
  final allowedParameters = _parameterBounds[id];
  if (id == null || allowedParameters == null) return null;

  final bands = <MvpDifficulty, Map<String, int>>{};
  for (final difficulty in MvpDifficulty.values) {
    final parameters = bandsValue[difficulty.value];
    if (parameters is! Map<String, dynamic> ||
        parameters.length != allowedParameters.length) {
      return null;
    }

    final parsedParameters = <String, int>{};
    for (final entry in parameters.entries) {
      final bounds = allowedParameters[entry.key];
      if (entry.value is! int ||
          bounds == null ||
          !bounds.contains(entry.value)) {
        return null;
      }
      parsedParameters[entry.key] = entry.value;
    }
    bands[difficulty] = Map.unmodifiable(parsedParameters);
  }

  if (bands.length != MvpDifficulty.values.length) return null;
  return MvpModuleConfig(
    id: id,
    enabled: enabled,
    difficultyBands: Map.unmodifiable(bands),
  );
}

const Map<MvpModuleId, Map<String, _ParameterBounds>> _parameterBounds = {
  MvpModuleId.reactionTap: {
    'cueDelayMs': _ParameterBounds(300, 3000),
    'targetSizePx': _ParameterBounds(32, 160),
    'distractorCount': _ParameterBounds(0, 8),
    'timeoutMs': _ParameterBounds(500, 10000),
  },
  MvpModuleId.sequenceMemory: {
    'sequenceLength': _ParameterBounds(2, 12),
    'displayMs': _ParameterBounds(150, 2000),
    'symbolCount': _ParameterBounds(2, 8),
    'timeoutMs': _ParameterBounds(1000, 20000),
  },
  MvpModuleId.selectiveAttention: {
    'itemCount': _ParameterBounds(2, 20),
    'similarity': _ParameterBounds(0, 100),
    'motionSpeed': _ParameterBounds(0, 100),
    'timeoutMs': _ParameterBounds(1000, 20000),
  },
  MvpModuleId.timingStop: {
    'speed': _ParameterBounds(1, 100),
    'zoneSize': _ParameterBounds(5, 80),
    'directionChanges': _ParameterBounds(0, 10),
  },
  MvpModuleId.logicChoice: {
    'ruleComplexity': _ParameterBounds(1, 5),
    'choiceCount': _ParameterBounds(2, 6),
    'timeoutMs': _ParameterBounds(1000, 20000),
  },
};

final class _ParameterBounds {
  const _ParameterBounds(this.minimum, this.maximum);

  final int minimum;
  final int maximum;

  bool contains(int value) => value >= minimum && value <= maximum;
}
