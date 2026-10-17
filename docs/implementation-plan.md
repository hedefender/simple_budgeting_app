# Phase 0 implementation plan

Each step ends in a state that analyzes and runs. Steps are in the order the
code was written.

| # | Step | Output | Done when |
| --- | --- | --- | --- |
| 1 | Project shell and dependencies | `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml` | `flutter pub get` succeeds |
| 2 | Localization | `app_en.arb`, `app_el.arb` | `flutter gen-l10n` generates `AppLocalizations` |
| 3 | Core value types | `Money`, `MoneyFormatter`, `Clock` | money unit tests pass |
| 4 | Database | `AppDatabase`, `AppSettings` table | `build_runner` generates `app_database.g.dart` |
| 5 | Domain | `AppStatus`, `AppStatusRepository`, two use cases | compiles with no Flutter/drift imports |
| 6 | Data | `AppStatusRepositoryImpl` | repository tests pass on in-memory SQLite |
| 7 | Bootstrapping | `Bootstrapper` | bootstrapper tests pass |
| 8 | Dependency injection | `configureDependencies` | DI graph test resolves and runs |
| 9 | State and UI | `BootstrapController`, splash, home, `BudgetApp` | widget tests pass |
| 10 | Persistence proof | temp-file integration test | launch count survives simulated restarts |
| 11 | On-device check | `integration_test/cold_start_test.dart`, manual validation | counter increments across real restarts |

## Exit criteria for Phase 0

- `flutter analyze` reports no issues.
- `flutter test` passes (unit, widget, host integration).
- App runs on an Android emulator or phone and shows the home screen.
- Launch counter keeps increasing after force-closing the app.
- Switching the device language between English and Greek changes the text.
- Cold-start time is recorded (see `manual-validation.md`).

## What Phase 1 will add (not started)

Income feature under `lib/features/income/`: `Income` entity, `IncomeRepository`,
drift `incomes` table with UUID primary key, recurring-income rules, use cases,
a basic cash-flow calculator, and a simple entry UI. Phase 1 begins only after
you confirm Phase 0 compiles and passes.
