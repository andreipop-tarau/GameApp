enum BrainSkill { reaction, memory, attention, logic, timing }

extension BrainSkillLabel on BrainSkill {
  String get label => switch (this) {
    BrainSkill.reaction => 'Reaction',
    BrainSkill.memory => 'Memory',
    BrainSkill.attention => 'Attention',
    BrainSkill.logic => 'Logic',
    BrainSkill.timing => 'Timing',
  };
}

final class BrainSkillEstimate {
  const BrainSkillEstimate({
    required this.value,
    required this.confidence,
    required this.sampleCount,
  });

  const BrainSkillEstimate.initial()
    : value = 50,
      confidence = 0,
      sampleCount = 0;

  final double value;
  final double confidence;
  final int sampleCount;
}

final class BrainProfile {
  const BrainProfile.initial()
    : reaction = const BrainSkillEstimate.initial(),
      memory = const BrainSkillEstimate.initial(),
      attention = const BrainSkillEstimate.initial(),
      logic = const BrainSkillEstimate.initial(),
      timing = const BrainSkillEstimate.initial(),
      _appliedOutcomeIds = const <String>{};

  BrainProfile._({
    required this.reaction,
    required this.memory,
    required this.attention,
    required this.logic,
    required this.timing,
    required Set<String> appliedOutcomeIds,
  }) : _appliedOutcomeIds = Set.unmodifiable(appliedOutcomeIds);

  final BrainSkillEstimate reaction;
  final BrainSkillEstimate memory;
  final BrainSkillEstimate attention;
  final BrainSkillEstimate logic;
  final BrainSkillEstimate timing;
  final Set<String> _appliedOutcomeIds;

  BrainSkillEstimate estimateFor(BrainSkill skill) => switch (skill) {
    BrainSkill.reaction => reaction,
    BrainSkill.memory => memory,
    BrainSkill.attention => attention,
    BrainSkill.logic => logic,
    BrainSkill.timing => timing,
  };

  int get totalSampleCount =>
      reaction.sampleCount +
      memory.sampleCount +
      attention.sampleCount +
      logic.sampleCount +
      timing.sampleCount;

  bool get hasSparseData =>
      BrainSkill.values.any((skill) => estimateFor(skill).sampleCount < 3);

  bool hasAppliedOutcome(String outcomeId) =>
      _appliedOutcomeIds.contains(outcomeId);

  Set<String> get appliedOutcomeIds => _appliedOutcomeIds;

  factory BrainProfile.restored({
    required BrainSkillEstimate reaction,
    required BrainSkillEstimate memory,
    required BrainSkillEstimate attention,
    required BrainSkillEstimate logic,
    required BrainSkillEstimate timing,
    required Set<String> appliedOutcomeIds,
  }) => BrainProfile._(
    reaction: reaction,
    memory: memory,
    attention: attention,
    logic: logic,
    timing: timing,
    appliedOutcomeIds: appliedOutcomeIds,
  );

  BrainProfile withAppliedOutcome({
    required String outcomeId,
    required BrainSkill skill,
    required BrainSkillEstimate estimate,
  }) {
    return BrainProfile._(
      reaction: skill == BrainSkill.reaction ? estimate : reaction,
      memory: skill == BrainSkill.memory ? estimate : memory,
      attention: skill == BrainSkill.attention ? estimate : attention,
      logic: skill == BrainSkill.logic ? estimate : logic,
      timing: skill == BrainSkill.timing ? estimate : timing,
      appliedOutcomeIds: {..._appliedOutcomeIds, outcomeId},
    );
  }
}
