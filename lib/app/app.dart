import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrap_controller.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrap_page.dart';
import 'package:simple_budgeting_app/features/foundation/presentation/home_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

class BudgetApp extends ConsumerWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bootstrapControllerProvider);
    final result = state.result;

    return MaterialApp(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: state.status == BootstrapStatus.ready && result != null
          ? HomePage(result: result)
          : BootstrapPage(state: state),
    );
  }
}
