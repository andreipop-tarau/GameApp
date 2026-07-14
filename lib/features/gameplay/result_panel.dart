import 'package:flutter/material.dart';

import 'challenge.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({
    required this.evaluation,
    required this.xpDelta,
    required this.onAgain,
    required this.onHome,
    super.key,
  });

  final RoundEvaluation evaluation;
  final int xpDelta;
  final VoidCallback onAgain;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final won = evaluation.outcome == ChallengeOutcome.success;
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                won ? 'Round complete' : 'Round missed',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                won ? 'You solved it.' : 'Try the next round.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('+$xpDelta XP', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(onPressed: onAgain, child: const Text('Again')),
              TextButton(onPressed: onHome, child: const Text('Home')),
            ],
          ),
        ),
      ),
    );
  }
}
