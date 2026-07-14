import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'challenge.dart';
import 'challenges/logic_choice/logic_choice.dart';
import 'challenges/reaction_tap/reaction_tap.dart';
import 'challenges/selective_attention/selective_attention.dart';
import 'challenges/sequence_memory/sequence_memory.dart';
import 'challenges/timing_stop/timing_stop.dart';
import 'game_session_controller.dart';
import 'result_panel.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  Timer? _ticker;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startRound();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startRound() {
    _ticker?.cancel();
    _stopwatch
      ..reset()
      ..start();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
    ref.read(gameSessionControllerProvider.notifier).startRound();
  }

  void _goHome() {
    _ticker?.cancel();
    ref.read(gameSessionControllerProvider.notifier).exit();
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play'),
        actions: [TextButton(onPressed: _goHome, child: const Text('Home'))],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (session.status) {
            GameSessionStatus.idle || GameSessionStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            GameSessionStatus.active => Center(
              child: _ActiveChallenge(
                plan: session.plan!,
                elapsed: _stopwatch.elapsed,
                onAction: (action) {
                  _ticker?.cancel();
                  _stopwatch.stop();
                  ref
                      .read(gameSessionControllerProvider.notifier)
                      .submit(action, _stopwatch.elapsed);
                },
              ),
            ),
            GameSessionStatus.result => ResultPanel(
              evaluation: session.evaluation!,
              onAgain: _startRound,
              onHome: _goHome,
            ),
            GameSessionStatus.failure => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to start a round. Please try again.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _startRound,
                    child: const Text('Try again'),
                  ),
                  TextButton(onPressed: _goHome, child: const Text('Home')),
                ],
              ),
            ),
          },
        ),
      ),
    );
  }
}

class _ActiveChallenge extends StatelessWidget {
  const _ActiveChallenge({
    required this.plan,
    required this.elapsed,
    required this.onAction,
  });

  final RoundPlan plan;
  final Duration elapsed;
  final ValueChanged<PlayerAction> onAction;

  @override
  Widget build(BuildContext context) => switch (plan.moduleId) {
    'reaction_tap' => ReactionTapWidget(
      plan: plan,
      elapsed: elapsed,
      onAction: onAction,
    ),
    'sequence_memory' => SequenceMemoryWidget(
      plan: plan,
      elapsed: elapsed,
      onAction: onAction,
    ),
    'selective_attention' => SelectiveAttentionWidget(
      plan: plan,
      elapsed: elapsed,
      onAction: onAction,
    ),
    'timing_stop' => TimingStopWidget(
      plan: plan,
      elapsed: elapsed,
      onAction: onAction,
    ),
    'logic_choice' => LogicChoiceWidget(
      plan: plan,
      elapsed: elapsed,
      onAction: onAction,
    ),
    _ => const Text('This challenge is unavailable.'),
  };
}
