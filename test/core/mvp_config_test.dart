import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/mvp_config.dart';

void main() {
  String bundledConfig() => File(mvpChallengesAssetPath).readAsStringSync();

  test('parses the bundled MVP configuration', () {
    final result = parseMvpConfig(bundledConfig());

    expect(result, isA<MvpConfigLoaded>());
    final config = (result as MvpConfigLoaded).config;
    expect(config.schemaVersion, 1);
    expect(config.modules, hasLength(5));
  });

  test('returns a typed failure for malformed configuration', () {
    expect(
      parseMvpConfig('{'),
      isA<MvpConfigFailure>().having(
        (failure) => failure.reason,
        'reason',
        MvpConfigFailureReason.malformed,
      ),
    );
  });

  test('returns a typed failure for unsupported schema', () {
    final source = bundledConfig().replaceFirst(
      '"schemaVersion": 1',
      '"schemaVersion": 2',
    );

    expect(
      parseMvpConfig(source),
      isA<MvpConfigFailure>().having(
        (failure) => failure.reason,
        'reason',
        MvpConfigFailureReason.unsupportedSchema,
      ),
    );
  });

  test('rejects out-of-bounds module parameters', () {
    final source = bundledConfig().replaceFirst(
      '"targetSizePx": 112',
      '"targetSizePx": 161',
    );

    expect(
      parseMvpConfig(source),
      isA<MvpConfigFailure>().having(
        (failure) => failure.reason,
        'reason',
        MvpConfigFailureReason.invalidParameters,
      ),
    );
  });
}
