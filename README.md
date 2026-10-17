# Simple Budgeting App

Privacy-first, fully local personal budgeting app (Flutter, Android first).

**Current status: Phase 0 – Foundation.** The app boots through a splash/progress
screen, opens a local SQLite database (drift), records launches, and shows the
result on a placeholder home screen in English or Greek with device-locale
currency formatting. No budgeting features yet; those start in Phase 1.

## 1. One-time setup (after Flutter is installed)

Check the toolchain first: `flutter doctor` must show Flutter, Android toolchain
and an Android emulator or a USB-debugging phone with no blocking errors.

This archive contains the project files but **not** the generated `android/`
platform folder, so create the Flutter shell first and copy these files over it.

```bash
# 1. Create the Flutter project shell (placeholder Android id, see docs/architecture.md)
flutter create --org com.example --project-name simple_budgeting_app --platforms android simple_budgeting_app

# 2. Copy the CONTENTS of this archive over it, overwriting when asked:
#    pubspec.yaml, analysis_options.yaml, l10n.yaml, lib/, test/, integration_test/, docs/, README.md
#    Then delete the generated sample test:
#    simple_budgeting_app/test/widget_test.dart

cd simple_budgeting_app
flutter pub get                       # also runs gen-l10n (generate: true)
dart pub upgrade --tighten            # turns the `any` constraints into ^x.y.z
dart run build_runner build --delete-conflicting-outputs   # generates lib/core/database/app_database.g.dart
flutter analyze
flutter test
flutter run                           # emulator or phone
```

Windows PowerShell: the same commands work; copy the files with Explorer or
`Copy-Item -Recurse -Force <archive>\* .\simple_budgeting_app\`.

Whenever you change a drift table, rerun the `build_runner` line. While
developing you can use `dart run build_runner watch --delete-conflicting-outputs`.

## 2. Running the tests

| What | Command | Needs a device |
| --- | --- | --- |
| Unit + widget + host integration | `flutter test` | No |
| Only the persistence integration test | `flutter test test/integration` | No |
| On-device integration (real DB file) | `flutter test integration_test/cold_start_test.dart -d <device-id>` | Yes |

`flutter devices` lists device ids.

## 3. Documentation

- `docs/architecture.md` – layers, folder structure, decisions
- `docs/implementation-plan.md` – ordered steps and "done" criteria for Phase 0
- `docs/di-and-state-management.md` – get_it and Riverpod explained, and how to choose per project
- `docs/manual-validation.md` – how to check Phase 0 by hand, including cold-start timing
- `docs/roadmap.md` – current position, Rust vs Dart split per phase, open decisions
- `CLAUDE.md` – project rules for Claude Code (commands, architecture rules, workflow)

## 4. Known placeholders

- Android `applicationId`: `com.example.simple_budgeting_app`. Change before the
  first Google Play upload (and before Phase 8, which depends on it).
- Greek strings in `lib/l10n/app_el.arb` are a first draft; please review them.
