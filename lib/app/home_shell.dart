import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_budgeting_app/app/bootstrap/bootstrapper.dart';
import 'package:simple_budgeting_app/features/foundation/presentation/home_page.dart';
import 'package:simple_budgeting_app/features/income/presentation/income_page.dart';
import 'package:simple_budgeting_app/features/settings/presentation/settings_providers.dart';
import 'package:simple_budgeting_app/features/setup/presentation/setup_wizard_page.dart';
import 'package:simple_budgeting_app/l10n/app_localizations.dart';

/// The main screen once the app is ready: bottom navigation between Home and
/// Income. Both tabs stay alive so their state survives tab switches. On a
/// fresh install it opens the setup wizard once.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.result});

  final BootstrapResult result;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowSetup());
  }

  Future<void> _maybeShowSetup() async {
    final show = await ref.read(shouldShowSetupProvider.future);
    if (!show || !mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SetupWizardPage()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          HomePage(result: widget.result),
          const IncomePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: <NavigationDestination>[
          NavigationDestination(
            key: const Key('nav-home'),
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            key: const Key('nav-income'),
            icon: const Icon(Icons.payments_outlined),
            selectedIcon: const Icon(Icons.payments),
            label: l10n.navIncome,
          ),
        ],
      ),
    );
  }
}
