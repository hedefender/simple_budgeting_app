import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';

enum BootstrapStatus { running, ready, failed }

@immutable
class BootstrapState {
  const BootstrapState({
    required this.status,
    this.stage = BootstrapStage.startingCore,
    this.fraction = 0,
    this.result,
    this.error,
  });

  const BootstrapState.initial() : this(status: BootstrapStatus.running);

  final BootstrapStatus status;
  final BootstrapStage stage;
  final double fraction;
  final BootstrapResult? result;
  final Object? error;
}

/// Holds the startup state for the UI. Starting is automatic; [start] can be
/// called again to retry after a failure.
class BootstrapController extends Notifier<BootstrapState> {
  @override
  BootstrapState build() {
    unawaited(Future<void>.microtask(start));
    return const BootstrapState.initial();
  }

  Future<void> start() async {
    state = const BootstrapState.initial();
    try {
      final result = await ref.read(bootstrapperProvider).run(
        onProgress: (BootstrapProgress p) {
          state = BootstrapState(
            status: BootstrapStatus.running,
            stage: p.stage,
            fraction: p.fraction,
          );
        },
      );
      state = BootstrapState(
        status: BootstrapStatus.ready,
        stage: BootstrapStage.finishing,
        fraction: 1,
        result: result,
      );
    } catch (error, stackTrace) {
      debugPrint('Bootstrap failed: $error\n$stackTrace');
      state = BootstrapState(status: BootstrapStatus.failed, error: error);
    }
  }
}

final NotifierProvider<BootstrapController, BootstrapState>
    bootstrapControllerProvider =
    NotifierProvider<BootstrapController, BootstrapState>(
  BootstrapController.new,
);
