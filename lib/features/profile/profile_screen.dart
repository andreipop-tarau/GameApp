import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../brain_profile/brain_profile.dart';
import '../brain_profile/brain_profile_provider.dart';

final class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(brainProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Brain Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'A private, descriptive summary of your challenge results. '
            'It does not affect gameplay.',
          ),
          if (profile.hasSparseData) ...[
            const SizedBox(height: 16),
            Semantics(
              container: true,
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Not enough data yet'),
                      SizedBox(height: 4),
                      Text(
                        'Complete more challenges to build a steadier '
                        'description. Early estimates may change.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          for (final skill in BrainSkill.values) ...[
            _SkillCard(skill: skill, estimate: profile.estimateFor(skill)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

final class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill, required this.estimate});

  final BrainSkill skill;
  final BrainSkillEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final confidencePercent = (estimate.confidence * 100).round();
    final estimateText = estimate.sampleCount == 0
        ? 'No estimate yet'
        : '${estimate.value.round()} / 100';
    final semanticsValue = estimate.sampleCount == 0
        ? 'Not enough data. Confidence $confidencePercent percent. '
              '${estimate.sampleCount} samples.'
        : '$estimateText. Confidence $confidencePercent percent. '
              '${estimate.sampleCount} samples.';

    return Semantics(
      container: true,
      label: '${skill.label} skill',
      value: semanticsValue,
      readOnly: true,
      child: ExcludeSemantics(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        skill.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(estimateText),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: estimate.sampleCount == 0 ? 0 : estimate.value / 100,
                ),
                const SizedBox(height: 10),
                Text('Confidence: $confidencePercent%'),
                Text('Samples: ${estimate.sampleCount}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
