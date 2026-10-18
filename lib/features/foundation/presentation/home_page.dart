import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/core/money/money.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Phase 0 home screen. It only proves that persistence, localization and
/// locale-aware money formatting work. Real features arrive from Phase 1.
class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.result});

  final BootstrapResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final formatter = ref.watch(moneyFormatterProvider);
    final deviceLocale = ref.watch(deviceLocaleProvider);
    final coreInfo = ref.watch(coreInfoServiceProvider).read();
    final status = result.status;
    final previousStartup = status.lastStartupMs;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(l10n.homeIntro),
          const SizedBox(height: 16),
          _InfoTile(
            key: const Key('launch-count'),
            icon: Icons.rocket_launch_outlined,
            text: l10n.homeLaunchCount(status.launchCount),
          ),
          _InfoTile(
            key: const Key('first-launch'),
            icon: Icons.event_outlined,
            text: l10n.homeFirstLaunch(status.firstLaunchAt.toLocal()),
          ),
          _InfoTile(
            key: const Key('startup-this'),
            icon: Icons.timer_outlined,
            text: l10n.homeStartupThisLaunch(result.elapsed.inMilliseconds),
          ),
          _InfoTile(
            key: const Key('startup-previous'),
            icon: Icons.history,
            text: previousStartup == null
                ? l10n.homeStartupNoPrevious
                : l10n.homeStartupPreviousLaunch(previousStartup),
          ),
          _InfoTile(
            key: const Key('rust-core'),
            icon: Icons.memory,
            text: l10n.homeRustCore(coreInfo.crateVersion, coreInfo.target),
          ),
          _InfoTile(
            key: const Key('locale-info'),
            icon: Icons.language,
            text: l10n.homeLocaleInfo(
              deviceLocale.toString(),
              formatter.currencyCode,
            ),
          ),
          _InfoTile(
            key: const Key('money-sample'),
            icon: Icons.payments_outlined,
            text: l10n.homeMoneySample(formatter.format(const Money(123456))),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(text)),
    );
  }
}
