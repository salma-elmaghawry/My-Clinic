import 'dart:math';

final Random _random = Random();

/// Unique-enough local id: microsecond timestamp plus a random suffix, so
/// two records created in the same microsecond still get different ids.
String generateId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final suffix = _random.nextInt(1 << 32).toRadixString(36);
  return '$time$suffix';
}
