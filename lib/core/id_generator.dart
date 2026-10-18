import 'dart:math';

/// A source of new unique ids (UUID text). Injected so tests get stable ids.
typedef IdGenerator = String Function();

final Random _secureRandom = Random.secure();

/// A random (version 4) UUID, for example
/// `3f2b8c1e-5a4d-4b7e-9c10-0d2f6a8e1b34`.
String generateUuidV4() {
  final bytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
