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

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startRound();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  void _startRound() {
    final status = ref.read(gameSessionControllerProvider).status;
    if (status == GameSessionStatus.active ||
        status == GameSessionStatus.loading) {
      return;
    }
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _ticker?.cancel();
        _stopwatch.stop();
        ref.read(gameSessionControllerProvider.notifier).abandonActiveRound();
      case AppLifecycleState.resumed:
        if (ref.read(gameSessionControllerProvider).status ==
            GameSessionStatus.idle) {
          _startRound();
        }
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _requestExit() async {
    if (ref.read(gameSessionControllerProvider).status !=
        GameSessionStatus.active) {
      _goHome();
      return;
    }
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave round?'),
        content: const Text('This round will be abandoned.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) _goHome();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(gameSessionControllerProvider);
    return PopScope(
      canPop: session.status != GameSessionStatus.active,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && session.status == GameSessionStatus.active) {
          _requestExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Play'),
          actions: [
            TextButton(onPressed: _requestExit, child: const Text('Home')),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: switch (session.status) {
              GameSessionStatus.idle || GameSessionStatus.loading =>
                const Center(child: CircularProgressIndicator()),
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
                xpDelta: session.xpDelta!,
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
