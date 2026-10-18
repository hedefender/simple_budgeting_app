import 'package:flutter/foundation.dart';

/// Build information about the native (Rust) core.
@immutable
class CoreInfo {
  const CoreInfo({required this.crateVersion, required this.target});

  final String crateVersion;

  /// Platform the native library was compiled for, e.g. `x86_64-android`.
  final String target;

  @override
  bool operator ==(Object other) =>
      other is CoreInfo &&
      other.crateVersion == crateVersion &&
      other.target == target;

  @override
  int get hashCode => Object.hash(crateVersion, target);
}
