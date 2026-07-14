import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/local_game_save.dart';
import 'features/brain_profile/brain_profile_provider.dart';
import 'features/gameplay/game_session_controller.dart';
import 'features/progression/progression.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LocalGameSaveStore(await SharedPreferences.getInstance());
  final loadResult = await store.load();
  runApp(
    MindTrapApp(
      container: ProviderContainer(
        overrides: [
          initialBrainProfileProvider.overrideWithValue(
            loadResult.save.brainProfile,
          ),
          initialProgressionProvider.overrideWithValue(
            loadResult.save.progression,
          ),
          initialLocalGameSaveProvider.overrideWithValue(loadResult.save),
          localGameSaveStoreProvider.overrideWithValue(store),
        ],
      ),
    ),
  );
}
