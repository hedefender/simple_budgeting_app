# Architecture (Phase 0)

## Goals

- Maintainability and testability first, feature count second.
- Fully local: no network, no account, no cloud.
- Every phase leaves a runnable app.
- Android first; iOS and a future PC companion must not require rewrites.

## Layers and the dependency rule

```
presentation  ->  domain  <-  data
     \________________|________/
                  app (composition root)
```

- **domain**: entities, repository *interfaces*, use cases. Pure Dart. It knows
  nothing about Flutter, drift or SQLite.
- **data**: implements domain interfaces (drift queries, later: JSON import,
  rule engine). It depends on domain, never the other way round.
- **presentation**: widgets and Riverpod state. It talks to use cases and
  repositories through domain types only.
- **app**: the composition root. It is the only place that wires concrete
  classes together (get_it) and starts the app.

Rule of thumb: an `import` in `domain/` of `package:flutter`, `package:drift`
or `data/` is a bug.

## Folder structure

```
lib/
  main.dart                      entry point: configure DI, run app
  app/
    app.dart                     MaterialApp, localization, splash vs. home
    bootstrap/
      bootstrapper.dart          cold-start work + timing (no UI, no strings)
      bootstrap_controller.dart  Riverpod Notifier exposing startup state
      bootstrap_page.dart        splash screen with progress bar
    di/
      service_locator.dart       get_it registrations (composition root)
      providers.dart             bridge get_it -> Riverpod, device locale, money formatter
  core/
    clock.dart                   injectable "now"
    database/
      app_database.dart          the single drift database
      tables/app_settings.dart   key/value table (Phase 0)
    money/
      money.dart                 integer minor-unit value type
      money_formatter.dart       locale/currency formatting via intl
  features/
    foundation/                  Phase 0 feature (launch tracking)
      domain/{entities,repositories,usecases}
      data/app_status_repository_impl.dart
      presentation/home_page.dart
  l10n/
    app_en.arb, app_el.arb       translations (gen_l10n)
test/ ...                        mirrors lib/ (see README)
integration_test/                on-device tests
```

New features become `lib/features/<name>/{domain,data,presentation}` (income,
expenses, categories, ...). Shared infrastructure stays in `core/`.

## Cold start flow

1. `main()` creates the get_it graph (nothing heavy is built yet: all
   registrations are lazy) and runs the app inside a Riverpod `ProviderScope`.
2. `BootstrapController` starts the `Bootstrapper` and publishes progress.
3. `Bootstrapper` stages: open database (drift creates the file and runs
   migrations on first access) -> record launch -> persist the measured duration.
4. While running, `BootstrapPage` shows a progress bar. When ready, `BudgetApp`
   swaps to `HomePage`. On failure a retry button appears.

The splash is always shown in Phase 0 on purpose: we measure first (the duration
is displayed on the home screen and printed to the log). If startup is fast on
real devices we can hide the splash until a threshold is crossed.

## Data decisions

| Decision | Why |
| --- | --- |
| drift over raw sqflite | Type-safe queries, generated code, reactive streams, built-in migration tooling and in-memory databases for tests |
| UUID primary keys on future domain tables | A PC version with sync would otherwise collide on auto-increment ids |
| Money as integer minor units | No floating-point errors; `double` only appears when formatting |
| Currency/locale from the device | Request from the project brief; device region decides currency (`el_GR` -> EUR). Phase 1+ stores a currency code with each amount so a later per-user override is possible |
| Database executor injected | Production: file database (`drift_flutter`). Tests: in-memory or temp file |
| All UI text in ARB files | English first, Greek included; adding a language = adding one ARB file |

## Testability

- `Clock` and the database executor are injected, so tests control time and storage.
- `configureDependencies(GetIt locator, ...)` takes the locator as a parameter;
  tests use `GetIt.asNewInstance()` for isolated graphs.
- Widget tests replace the graph through `serviceLocatorProvider`.
- The bootstrapper has no Flutter UI dependency and is unit tested with fakes.

## Android package id

`flutter create --org com.example` yields `com.example.simple_budgeting_app`
as a **placeholder**. Google Play rejects `com.example.*`. Changing it later
means editing `android/app/build.gradle(.kts)` (`namespace` and `applicationId`),
the Kotlin package folder and `AndroidManifest.xml`. Decide a final prefix before
Phase 8 (Scan integration), since Intents and App Links reference it.

## Rust core (planned, Phase 0b)

Rust handles compute and cross-platform interconnection; Flutter handles UI and persistence.
See `roadmap.md` for the split per phase.

```
presentation -> domain (interface, e.g. ReceiptParser) <- data (adapter) -> generated bridge -> Rust crate
```

- The Rust crate is stateless: data in, structured result out. It does not open the SQLite file
  (a second writer next to drift would be a source of corruption and double migrations).
- Domain code never imports the generated bridge. A data-layer adapter wraps it, so the rest of the app
  is tested with fakes and Rust is tested alone with `cargo test`.
- Across the bridge: plain structs, `i64` minor units for money, UTC timestamps, typed error enums.
- All app versions, including the final desktop version, are Flutter, so persistence stays in Dart/drift.
