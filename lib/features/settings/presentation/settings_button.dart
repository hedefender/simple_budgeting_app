import 'package:flutter/material.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// App bar action that opens the Settings page.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('open-settings'),
      tooltip: AppLocalizations.of(context).settingsOpen,
      icon: const Icon(Icons.settings_outlined),
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
    );
  }
}
