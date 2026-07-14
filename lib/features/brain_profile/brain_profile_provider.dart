import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brain_profile.dart';
import 'brain_profile_updater.dart';

final brainProfileProvider =
    NotifierProvider<BrainProfileController, BrainProfile>(
      BrainProfileController.new,
    );

final class BrainProfileController extends Notifier<BrainProfile> {
  BrainProfileController([this._updater = const BrainProfileUpdater()]);

  final BrainProfileUpdater _updater;

  @override
  BrainProfile build() => const BrainProfile.initial();

  BrainProfileUpdateResult applyOutcome(BrainProfileOutcome outcome) {
    final result = _updater.apply(state, outcome);
    if (result.wasApplied) state = result.profile;
    return result;
  }
}
