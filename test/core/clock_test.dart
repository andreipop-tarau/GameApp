import 'package:flutter_test/flutter_test.dart';
import 'package:mindtrap_ai/core/clock.dart';

void main() {
  test('fixed clock returns its supplied time', () {
    final time = DateTime.utc(2026, 7, 14, 12);

    expect(FixedClock(time).now(), time);
  });
}
