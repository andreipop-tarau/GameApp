import 'dart:math';

final class SeededRandom {
  SeededRandom(this.seed) : _random = Random(seed);

  final int seed;
  final Random _random;

  bool nextBool() => _random.nextBool();

  double nextDouble() => _random.nextDouble();

  int nextInt(int max) => _random.nextInt(max);
}
