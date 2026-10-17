import 'package:flutter/foundation.dart';

/// Facts about the app's own lifetime, persisted locally.
@immutable
class AppStatus {
  const AppStatus({
    required this.launchCount,
    required this.firstLaunchAt,
    this.lastStartupMs,
  });

  /// How many times the app has been launched, including this one.
  final int launchCount;

  /// When the very first launch happened (UTC).
  final DateTime firstLaunchAt;

  /// Startup duration recorded by the previous launch, if any.
  final int? lastStartupMs;

  @override
  bool operator ==(Object other) =>
      other is AppStatus &&
      other.launchCount == launchCount &&
      other.firstLaunchAt == firstLaunchAt &&
      other.lastStartupMs == lastStartupMs;

  @override
  int get hashCode => Object.hash(launchCount, firstLaunchAt, lastStartupMs);

  @override
  String toString() =>
      'AppStatus(launchCount: $launchCount, firstLaunchAt: $firstLaunchAt, '
      'lastStartupMs: $lastStartupMs)';
}
