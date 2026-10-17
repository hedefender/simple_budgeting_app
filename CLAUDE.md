# Simple Budgeting App

Privacy-first, fully local personal budgeting app. Flutter/Dart UI, Rust compute core
(via flutter_rust_bridge). Android first, then iOS, with a Flutter desktop version as the final phase.
Dart package name: `simple_budgeting_app`. Display name may change later.

## How to work with the owner

- If a request is missing information, ask a short clarifying question instead of assuming.
- Explain in Greek unless the owner writes in English. Code, comments, identifiers and docs stay in English.
- Work in small increments. Never generate the whole application at once.
- Every phase, in this order: 1) architecture, 2) implementation plan, 3) source code,
  4) unit tests, 5) integration tests, 6) how to validate manually,
  7) wait for the owner to confirm it compiles and passes before starting the next phase.
- Every phase must leave a runnable app. Prefer maintainability and testability over feature count.
- Say plainly what you could not verify. Do not claim a build or test passed unless you ran it.
- Do not commit, push or change the Android `applicationId` unless asked
  (placeholder `com.example.simple_budgeting_app`, final id decided before Phase 8).

## Stack (verified October 2026; re-check before bumping)

- Flutter 3.47.7 stable, Dart 3.13.5 (owner's machine, Windows 11), Rust 1.95.0
- State: `flutter_riverpod` ^3.4.1. DI: `get_it` ^9.2.1. Database: `drift` ^2.35.0 (+ `drift_flutter`)
- Rust bridge: `flutter_rust_bridge` 2.13.x. The codegen version should match the package version.
- Localization: ARB files in `lib/l10n` (English template, Greek). All UI text goes through them.
- Currency and locale come from the device, never hard-coded.

## Commands (PowerShell, project root)

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # drift generated code
flutter analyze
flutter test                                               # unit + widget + host integration
flutter test integration_test/cold_start_test.dart -d <device-id>   # on device
flutter run -d <device-id>
# After the Rust crate is added (Phase 0b):
flutter_rust_bridge_codegen generate
cargo test --manifest-path rust/Cargo.toml
```

Run `flutter analyze` and `flutter test` (and `cargo test` once Rust exists) after every change.

## Architecture rules

- Layers per feature: `lib/features/<name>/{domain,data,presentation}`; shared code in `lib/core`;
  wiring in `lib/app`. See `docs/architecture.md`.
- `domain` is pure Dart: no `package:flutter`, `drift`, or generated bridge imports.
  It owns repository and service interfaces.
- `data` implements domain interfaces (drift, Rust bridge adapters).
- Only `lib/app/di/service_locator.dart` knows concrete implementations. Business classes get
  dependencies through constructors and never call `GetIt.instance`.
- Inject `Clock` and the database executor so tests control time and storage.
- Money is `Money` (integer minor units). Never use `double` for stored or summed amounts.
- Domain tables use UUID text primary keys (future sync with a PC version).
- Dates are stored as UTC.

## Rust boundary

- The Rust crate is a stateless compute engine: JSON import parsing, rule engine, local LLM
  providers, budget intelligence, later sync/merge logic. It does not own SQLite: persistence stays
  in Dart/drift (all versions, including the final desktop version, are Flutter).
- Data crossing the bridge: plain structs, amounts as `i64` minor units, typed error enums.
- Rust logic is tested with `cargo test`. Dart wraps the generated API behind a domain interface so
  the rest of the app can be tested with fakes.
- Do not hand-edit generated files: `*.g.dart`, `lib/l10n/app_localizations*.dart`, and the
  flutter_rust_bridge output (by default `lib/src/rust/**` and `rust/src/frb_generated.rs`).
  Change the source and regenerate.

## Privacy

- Fully local, no accounts, no analytics, no cloud. No network access unless a phase explicitly adds it
  (for example model download in Phase 7, optional sync later) and the owner approves it.
- Never log amounts, vendors or OCR text in release builds.
- Owner's principle: the user's data belongs to the user and never sits on a vendor server. Any future sync
  uses files or cloud storage that the user owns, and the desktop version is the final phase.

## Roadmap

See `docs/roadmap.md`. Current position is recorded at the top of that file.
