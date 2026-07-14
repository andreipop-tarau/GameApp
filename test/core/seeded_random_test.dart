import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/seeded_random.dart';

void main() {
  test('same seed produces the same sequence', () {
    final first = SeededRandom(42);
    final second = SeededRandom(42);

    expect(
      List.generate(10, (_) => first.nextInt(1000)),
      List.generate(10, (_) => second.nextInt(1000)),
    );
  });
}
