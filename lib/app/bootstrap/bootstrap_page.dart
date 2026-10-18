import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrap_controller.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Splash screen with a progress bar, shown while the app bootstraps.
class BootstrapPage extends ConsumerWidget {
  const BootstrapPage({super.key, required this.state});

  final BootstrapState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final failed = state.status == BootstrapStatus.failed;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (failed) ...<Widget>[
                  Text(
                    l10n.bootstrapFailedTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('bootstrap-retry'),
                    onPressed: () =>
                        ref.read(bootstrapControllerProvider.notifier).start(),
                    child: Text(l10n.bootstrapRetry),
                  ),
                ] else ...<Widget>[
                  LinearProgressIndicator(value: state.fraction),
                  const SizedBox(height: 12),
                  Text(_label(l10n, state.stage)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _label(AppLocalizations l10n, BootstrapStage stage) {
    return switch (stage) {
      BootstrapStage.startingCore => l10n.bootstrapStartingCore,
      BootstrapStage.openingDatabase => l10n.bootstrapOpeningDatabase,
      BootstrapStage.recordingLaunch => l10n.bootstrapRecordingLaunch,
      BootstrapStage.finishing => l10n.bootstrapFinishing,
    };
  }
}
