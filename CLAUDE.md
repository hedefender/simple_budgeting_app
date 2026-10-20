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
# Rust core (crate in rust/; bridge Dart output in lib/src/rust, config in flutter_rust_bridge.yaml):
flutter_rust_bridge_codegen generate                       # after editing rust/src/api/**
cargo test --manifest-path rust/Cargo.toml
```

Run `flutter analyze` and `flutter test` (and `cargo test` once Rust exists) after every change.

## Product decisions

- Budget and Scan are independent apps. Each is fully usable alone; neither requires the other.
  They may exchange data (Scan JSON, later intents/deep links).
- Android ABIs for now: x86_64 and i686 only (intended; NOT yet enforced in Gradle, see `docs/roadmap.md`). Known limitation: the app cannot run on a physical ARM phone
  until `aarch64-linux-android` (later `armv7`) is added.
- Phase 4b (Pro): direct JPEG/PDF import with on-device OCR behind a domain interface `OcrEngine`
  (image/PDF bytes -> text). It produces the same `RawDocument` shape as Scan JSON. See `docs/roadmap.md`.

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
- Dates are stored as UTC. Instants are UTC; calendar days are `CalendarDate` (stored as text `yyyy-MM-dd`,
  arithmetic in `DateTime.utc`, never in local time).
- Amounts are net (as received). No tax or contribution calculation.
- Income schedule logic (dates, working days, holidays) stays in Dart, not in Rust.

## Rust boundary

- The Rust crate lives in `rust/` INSIDE this repo. It belongs to Budget only and is not shared with Scan
  (Scan will not have a Rust engine). The earlier decision to keep a shared core outside the repo is cancelled.
- The core is a stateless compute engine: Scan JSON parsing, rule engine, local LLM
  providers, budget intelligence, later sync/merge logic, and possibly OCR (engine chosen in a spike in
  Phase 4b). It does not own SQLite: persistence stays
  in Dart/drift (all versions, including the final desktop version, are Flutter).
- Domain defines an interface; a `data` adapter calls the bridge. The bridge is never imported in `domain`.
- Data crossing the bridge: plain structs, amounts as `i64` minor units, typed error enums.
- Rust logic is tested with `cargo test`. Dart wraps the generated API behind a domain interface so
  the rest of the app can be tested with fakes.
- Never run dart format on the whole project; format only the files you changed.
- Drift schema changes: bump `schemaVersion`, add the migration step, then
  `dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/` and
  `dart run drift_dev schema generate drift_schemas/ test/generated_migrations/`. Commit `drift_schemas/`.
- Do not hand-edit generated files: `test/generated_migrations/**`, `*.g.dart`, `lib/l10n/app_localizations*.dart`, and the
  flutter_rust_bridge output (`lib/src/rust/**`, `rust/src/frb_generated.rs`, `rust_builder/cargokit/**`).
  Change the source and regenerate.

## Privacy

- Fully local, no accounts, no analytics, no cloud. No network access unless a phase explicitly adds it
  (for example model download in Phase 7, optional sync later) and the owner approves it.
- Never log amounts, vendors or OCR text in release builds.
- Owner's principle: the user's data belongs to the user and never sits on a vendor server. Any future sync
  uses files or cloud storage that the user owns, and the desktop version is the final phase.

## Lessons learned

- Host tests must never load the native library: pass `initNative: () async {}` to `configureDependencies` and
  fake `CoreInfoService`. flutter_rust_bridge throws if `RustLib.init()` runs twice, so the composition root checks
  `RustLib.instance.initialized`.
- Edit files containing Greek text with the Edit tool, not PowerShell `Get-Content`/`Set-Content` (Windows
  PowerShell 5.1 corrupts UTF-8 without BOM).

- In Riverpod 3, do not write `<Override>` on `overrides` lists; let Dart infer the type.
- Widget tests that fake the device locale set both `localesTestValue` and `clearLocalesTestValue` (via `addTearDown`).
- `l10n.yaml` has `nullable-getter: false`, so `AppLocalizations.of(context)` is non-null.
- Drift `customConstraints` entries must be string LITERALS. An interpolated constant is dropped silently from the table and from the schema dump; check the dump after adding a CHECK.
- Bridge types must not be enums with data (the generator then wants the `freezed` package): use a plain enum plus fields.

- Read `docs/architecture-decisions.md` (the ADRs) before architecture changes. ADRs change only with the owner's approval.

## Roadmap

See `docs/roadmap.md`. Current position is recorded at the top of that file.
