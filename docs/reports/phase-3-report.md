# Phase 3 report: Scan JSON import and documents

Date: 2026-10-20. Not committed. Phase 3 is NOT marked Done: it waits for the owner's manual check
(`docs/manual-validation.md` section 13, which I did not do) and for permission to run the on-device test.
Plan: `docs/phase-3-plan.md` ("Approved changes" on top). Decisions: `docs/roadmap.md` ("Phase 3 decisions").
File format: `docs/scan-json-schema.md`.

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 596 passed, 0 failed (464 at the start of Phase 3) |
| `cargo test --manifest-path rust/Cargo.toml` | 38 passed (2 at the start) |
| `cargo clippy --all-targets` | 0 warnings (the module denies `unwrap_used`, `expect_used`, `indexing_slicing`) |
| `rustfmt --check` on `scan_json.rs` | clean |
| `flutter build apk --debug` | built; cargokit built the Rust library for all four targets, among them `x86_64-linux-android` and `i686-linux-android`, with the new crates |
| `integration_test/document_import_test.dart` | written, **NOT RUN** (on-device tests need your permission) |

`flutter analyze` and `flutter test` were run after every step, `cargo test` whenever Rust or the bridge changed and at the
end of every step from 3 on. The on-device tests of earlier phases were not run again.

What I could NOT verify: the file chooser of Android (`file_selector`), the real Rust parser inside the app, the
JSON type filter, and how the screens look on a device. Host tests cannot load the native library, so the Dart side
is tested with a fake parser and the real parser with `cargo test`; the whole path through the real parser is only in
the on-device test and in your manual check.

## Step 1: schema check

A dump of the v4 code, written to a temporary folder, was identical to `drift_schemas/drift_schema_v4.json`
(`diff`). `PRAGMA foreign_keys = ON` is already in `beforeOpen`.

## What was built

1. **Docs first:** `docs/scan-json-schema.md` (v1, `language`, offset note, names cut to the last segment, BOM, limits, skip
   rule, legacy reader, file references decision), `docs/phase-3-plan.md` ("Approved changes"), roadmap (Phase 2 Done 2026-10-20,
   Phase 3 decisions, ADR-002 reconciliation with the points where the documents do not agree, the three Rust rules, open
   decisions #16 and #17 decided), one line in `CLAUDE.md`.
2. **Dependencies:** `file_selector ^1.1.0`; Rust `serde =1.0.229` (derive), `serde_json =1.0.154`, `sha2 =0.11.1`, all
   pinned and compatible with Rust 1.95 (`rust-version` of the crates: 1.56, 1.71, 1.88).
3. **Rust parser** (`rust/src/api/scan_json.rs`): canonical v1 and the legacy reader, ISO 8601 parser written by hand (no
   `chrono`), BOM, size guard, typed errors, no `unwrap`/`expect`. 36 tests plus 2 for the flat error. Fixtures in
   `test/fixtures/scan_json/` (read by `cargo test` too). The bridge was regenerated.
4. **Schema v5:** `imports` (per batch), `documents`, `expenses.document_id`; migration, dump, helpers; migration tests
   retargeted to v5 and a new v4 -> v5 group (with foreign keys on).
5. **Domain:** `ScanDocument`, `ImportBatch`, `DocumentType`, `ParsedScan`, `ImportFailure`, `ImportReport` (`Imported`,
   `Duplicate`, `Skipped`, `Failed`), `ImportScanFiles` and the small use cases, `DeleteDocument`.
6. **Data:** `DocumentRepositoryImpl`, `RustScanJsonParser`, `FileSelectorImportFilePicker` / `FileSelectorImportSource`; the
   expense repository got the link, a typed `documentNotFound` error and the two queries.
7. **DI and providers.**
8. **Screens:** Documents tab, import with progress, import report, detail (20,000 characters, "Show all" above the text),
   delete with a confirmation that names the expenses that stay. Strings in `app_en.arb` / `app_el.arb`.
9. **Create expense from a document:** date (local day) and description (first line, 80 characters) pre-filled, no amount and no
   category, the banner "From the document of ...", the link on save, kept when the expense is edited.
10. **Navigation:** fourth tab, `home_shell_test.dart` (there was no shell test before).
11. **Docs:** `architecture.md`, `manual-validation.md` section 13, this report.
12. **On-device test** `integration_test/document_import_test.dart` (not run).

## Differences from the plan, and why

- **Flat bridge types.** The generator stopped with "Please add freezed to your dev_dependencies" for an enum that carries data.
  `freezed` was not approved, so the error is a plain enum `ScanJsonErrorKind` plus detail fields and `created_at` is two fields
  (`created_at_utc_ms` or `created_at_local`). This is the same information you asked for, in a flat shape. Recorded in the
  roadmap and in `CLAUDE.md`.
- **No type filter on the chooser.** You asked to try the JSON filter on the emulator first. I did not, because that needs the
  device (interactive) and the on-device rule; the picker accepts every type, so nothing can be hidden, and a non-`.json`
  file is reported as skipped. The switch is `FileSelectorImportFilePicker(jsonOnly: true)`; step 2 of section 13 tells how to
  try it. Please tell me the result.
- **The ADR file is at `docs/architecture-decisions.md`**, not `docs/adr/`. I used the real path (also in the line in
  `CLAUDE.md`) and moved nothing. The file and `docs/brainstorming.md` are yours and untouched.
- **CHECK constraints of `documents`** use `trim(x, ' ' || char(9) || char(10) || char(13))`: SQLite's `trim(x)` removes only spaces,
  and a text of only line breaks passed the first version (found by a test). The parser rejects all Unicode white space; the
  CHECK is the second guard.
- **Drift lesson:** the first version built the CHECK strings from a constant. Drift silently dropped them from the table and the
  dump. Now literals; the lesson is in `CLAUDE.md`. The dump has all four.
- **The expenses of a document** providers moved into `expense_providers.dart` to avoid a cycle between the two presentation
  folders.
- **The upgrade path v1/v2/v3 -> v5:** the older steps create `expenses` in its current shape (with `document_id`), so
  `addColumn` runs only when upgrading from v4. All the old migration tests pass against v5.

## Things you should know

- `file_selector` pulls `cross_file` and, through it, the Dart package `http` into the dependency graph. Nothing in the app
  calls it. The merged debug manifest has only the `INTERNET` permission that Flutter's debug manifest always adds; `file_selector`
  adds no permission. A release build will show whether it is absent there (not checked).
- Section 13 step 13 depends on the time zone of the phone; the host tests use 12:00 UTC so they pass in any zone, but the
  midnight case is only in the manual check.
- `imports` rows are inserted at the start of a batch and the counts are updated at the end. If the app dies in the middle, the counts of
  that batch stay at 0 (documents already stored are kept). Accepted in the plan.
- Duplicate check and insert are two steps; the `UNIQUE` column is the real guard. Two imports at the same instant could
  report one file as an error (`storageError`) instead of a duplicate. The UI does not allow two imports at once.
- The `language` field is stored but not shown anywhere except the detail; `document_type` has no UI (as decided).

## Files to commit (your job; I did not commit)

Source and tests: everything shown by `git status` under `lib/`, `rust/src/`, `test/`, `integration_test/`, `docs/`.
Generated or locked files that must go into the commit with them:

- `drift_schemas/drift_schema_v5.json`
- `test/generated_migrations/schema_v5.dart` and the modified `test/generated_migrations/schema.dart`
- `lib/core/database/app_database.g.dart`
- `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_el.dart`
- `lib/src/rust/api/scan_json.dart`, `lib/src/rust/frb_generated.dart`, `frb_generated.io.dart`, `frb_generated.web.dart`,
  `rust/src/frb_generated.rs`
- `pubspec.yaml`, `pubspec.lock`, `rust/Cargo.toml`, `rust/Cargo.lock`
- `test/fixtures/scan_json/*` (12 small files; `malformed_empty_file.json` is 0 bytes on purpose, check that git keeps it)

Not mine, still untracked or modified from before: `docs/architecture-decisions.md`, `docs/brainstorming.md`.

## Final run (2026-10-21)

The owner did the manual check of section 13 and committed the Phase 3 code.

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 596 passed, 0 failed |
| `cargo test --manifest-path rust/Cargo.toml` | 38 passed, 0 failed |
| `integration_test/document_import_test.dart` | **FAILED** in the first two runs (1 test, same result); passes after the fix, see "Cause and fix" |

Integration test: device = AVD `Testing_Phone`, `emulator-5554` (checked with `adb -s emulator-5554 emu avd name` before each
run; `emulator-5556` = `Test_Phone` was not touched). Command: `flutter test integration_test/document_import_test.dart -d emulator-5554`.
The only test, "the real parser: import, duplicates, errors, restart, delete", stopped at line 102,
`expect(report.importedCount, 3)`: `Expected: <3>  Actual: <0>`. The code was not changed.

Reading only, not verified: `RustLib.init()` is called only by the `Bootstrapper` (`initNative` in `service_locator.dart`), and
this test builds the dependencies with `configureDependencies` and never runs the bootstrapper, so the real parser may be called
before the native library is initialized. To confirm, the test would have to print the failure kinds or call `RustLib.init()`
first; I did not do either, by the instruction not to change code.

### Cause and fix (2026-10-21)

Diagnosis first: the test now prints one line per file and calls the real parser directly. The run showed 9 files
`Failed(unexpected)`, `receipt.pdf` `Skipped`, and `parser threw StateError: Bad state: flutter_rust_bridge has not been
initialized. Did you forget to call await RustLib.init();`. So the cause was the one suspected: the test never loaded the Rust
library. It was a bug of the test, not of the app (the app loads the library in the `Bootstrapper`).

Fix, in `integration_test/document_import_test.dart` only: after each `configureDependencies` the test runs
`locator.get<Bootstrapper>().run()`, the same path as the app (`initNative` of the service locator), not its own `RustLib.init()`.
The failure message with the per-file lines stays. No application code changed.

Integration tests on AVD `Testing_Phone`, `emulator-5554` (name checked with `adb -s emulator-5554 emu avd name` before each run;
`Test_Phone` / `emulator-5556` not touched), each with `-d emulator-5554`:

| Test | Result |
| --- | --- |
| `document_import_test.dart` (1 test) | passed (after the fix) |
| `cold_start_test.dart` (2 tests) | passed |
| `expense_persistence_test.dart` (1 test) | passed |
| `income_persistence_test.dart` (2 tests) | passed |

`flutter analyze` is still clean after the change (the host tests and `cargo test` are not affected by a change in
`integration_test/`; they were run before it: 596 and 38 passed).

### Known issue — Phase 3: native library load errors are not shown (also in `docs/roadmap.md`)

`RustScanJsonParser` catches only `ScanJsonError`; `ImportScanFiles` turns any other error into `Failed(unexpected)` without
detail. A failure to load the native library should be a clear error for the user. Not fixed in this phase.

## Known issue — Phase 3: the picker does not filter to `.json` on Android

Seen in the owner's manual check: the Android file chooser lets the user select a PDF; the import reports it as skipped, so it
never becomes a document. From the code: `FileSelectorImportFilePicker.pick()` passes `XTypeGroup(label: 'JSON', extensions:
['json'], mimeTypes: ['application/json'])` to `openFiles` when `jsonOnly` is true and an empty list otherwise (the app uses the
default, false). Not fixed. Low priority, later phase. Also in `docs/roadmap.md`.

## What is left

Nothing for Phase 3: it is marked Done in the roadmap. The two known issues above are for a later phase.
