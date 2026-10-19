import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/di/providers.dart';
import 'package:simple_budgeting_app/features/settings/domain/usecases/set_primary_currency.dart';
import 'package:simple_budgeting_app/features/settings/presentation/currency_dropdown.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// Minimal settings: for now only the primary currency.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _setPrimary(WidgetRef ref, String code) async {
    await ref.read(serviceLocatorProvider).get<SetPrimaryCurrency>()(code);
    // The Income page watches this provider, so it refreshes too.
    ref.invalidate(primaryCurrencyProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primary = ref.watch(primaryCurrencyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          primary.when(
            data: (String code) => CurrencyDropdown(
              label: l10n.settingsPrimaryCurrency,
              value: code,
              onChanged: (String selected) => _setPrimary(ref, selected),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace _) =>
                Text(l10n.incomeLoadError, key: const Key('settings-error')),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.settingsPrimaryCurrencyHelp,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
