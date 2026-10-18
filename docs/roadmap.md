# Roadmap

## Current position

| Step | Status |
| --- | --- |
| Toolchain: Flutter 3.47.7, Dart 3.13.5, Android SDK, RustRover plugins, smoke test on a device | Done (2026-10-17) |
| Rust bridge smoke test (throwaway `flutter_rust_bridge_codegen create` project) | Done (2026-10-17) |
| Phase 0a: Flutter-only foundation (delivered zip) analyzes, tests and runs | Done (2026-10-17) |
| Phase 0b: add the Rust crate with a trivial function behind a domain interface (crate in `rust/` inside this repo) | Done (2026-10-18) |
| Phase 1a: income data model, manual entry, basic cash flow | Done (2026-10-19) |
| Phase 1b: full schedule engine | Next |
| Phase 1c, 2 and later | Not started |

Each step starts only after the owner confirms the previous one compiles and passes.

Phase 0a note: `flutter analyze` is clean and `flutter test` passes (25/25). The startup times seen so far
(about 1500 ms on hot restart, 3172 ms on the first launch) come from a debug build on an emulator. They will be
measured again on a profile build on a real phone.

Phase 0b note: `flutter analyze`, `flutter test` (26/26), `cargo test` and the on-device integration test on the
emulator (x86_64, Android 16) all pass. With no Gradle changes, running on the emulator (`flutter test -d` /
`flutter run -d`) makes cargokit build only `x86_64-linux-android` and `i686-linux-android`. A plain
`flutter build apk --debug` (no `--target-platform`) builds all four Android targets, including armv7 and aarch64
(it installed those two into rustup on its own); limiting that needs an `abiFilters` / `--target-platform`
change that the owner has to approve.
Startup before and after adding Rust (debug build, emulator, first start in the process, 3 runs each):
Phase 0a 756-868 ms, Phase 0b 726-981 ms. The difference is within noise. Profile builds on a real phone are
still to be measured.

Phase 1a note: `flutter analyze` is clean, `flutter test` passes (147/147), `cargo test` passes (2/2), the
integration tests pass on the emulator, and the owner's manual check of steps 1-9 passes. Details:
`docs/reports/phase-1a-report.md`.

## Product decisions

- **Budget and Scan are independent apps.** Each is fully usable alone; neither requires the other.
  They may exchange data (Scan JSON, later intents/deep links).
- **The Rust crate lives in `rust/` inside this repo.** It belongs to Budget only and is not shared with Scan
  (Scan will not have a Rust engine). The earlier decision to keep a shared core outside the repo is cancelled.
  Rust does compute: Scan JSON parsing, rule engine, LLM providers, budget intelligence, and possibly OCR
  (engine decided in a spike in Phase 4b).
- **Android ABIs for now: x86_64 and i686 only.** Known limitation: the app cannot run on a physical ARM phone
  until `aarch64-linux-android` (later `armv7`) is added.

## Division of work: Rust vs Dart/Flutter

Rust is a stateless compute engine. Dart owns persistence (drift) and the UI.

| Phase | Goal | Dart / Flutter | Rust |
| --- | --- | --- | --- |
| 0a | Foundation | Clean architecture, drift, get_it, Riverpod, l10n, tests | - |
| 0b | Rust bridge | Domain interface and bridge adapter | Crate skeleton, version/ping function, `cargo test` |
| 1a | Income: data model, manual entry, basic cash flow | Tables (UUID keys), one-off and monthly schedules, computed occurrences with stored overrides, balance anchors, cash flow of a month, entry UI | - |
| 1b | Income: full schedule engine | Weekly, 2 or 4 payments a month, last day, Nth working day, weekend/holiday shifting, offline Greek holiday calendar | - |
| 1c | Income: worker profiles and extra payments | Profiles (employee, freelancer, side-hustle), editable default extra payments with a Greek preset pack (rules are checked against official sources before they are implemented) | - |
| 2 | Expenses | Manual entry, editing, history, CRUD tests | - |
| 2b | Month close / reconciliation | Month close against an anchor, a separate "adjustment" entry for the difference | - |
| 3 | JSON import | File picker, import records, malformed-input messages | Parse and validate Scan JSON (single, multi, malformed). Reuse the owner's working parser |
| 4 | Rule engine | Test dataset runner | Amount, date, vendor, VAT detection; keyword rules; confidence score; datasets for ΔΕΗ, ΕΥΔΑΠ, Cosmote, supermarket, περίπτερο |
| 4b | Direct import of JPEG/PDF with on-device OCR (Pro) | `OcrEngine` domain interface and adapter, file/image picker, import through the existing pipeline | OCR engine integration (engine chosen in a spike) |
| 5 | Categories | Category CRUD, manual override UI | Auto-category matching from rule output |
| 6 | Dashboards | drift aggregate queries and streams, charts (fl_chart or syncfusion_flutter_charts) | - |
| 7 | Local LLM | Model management UI | `AiParser` providers (Rule, Phi, Gemma, Llama), confidence-based fallback. Reuse the owner's working LLM code |
| 8 | Scan integration | Installed-app detection, Intents, deep/App Links, shared storage | - |
| 9 | Budget intelligence | Alerts and UI | Monthly prediction, anomaly detection |
| Later | Sync | Export/import UI, cloud-storage picker | Merge of exported change sets (UUIDs, timestamps, tombstones) |
| Final | Desktop version | Flutter desktop build sharing the same Dart and Rust code; sync through user-owned files or cloud storage | Same crate (`rust/`) |

## Phase 1a decisions

- Amounts are net (as received). No tax or contribution calculation.
- Income occurrences are computed from the schedule, not stored. `income_entries` stores only occurrences the user
  skipped or changed (status `received` or `skipped`, plus the amount). Each entry points to the original date of
  the occurrence it replaces.
- An occurrence dated today or earlier counts as received unless it is skipped or its amount was changed (the
  changed amount is then used). Later occurrences are expected.
- Every source has a required `start_date` and an optional `end_date`; nothing is generated before the start,
  after the end, or after archiving.
- Freeze history on edit: before a change to the amount or schedule of a source is applied, its occurrences up to
  today that are not stored yet are stored as `received` with the old values.
- Balance anchors: the anchor is the balance at the END of its day. Balance at date D = the last anchor dated
  on or before D, plus income dated after that anchor. Without an anchor the balance is 0 and all income since the
  source started counts.
- Known limit: if the device region changes, the currency of an existing source stays as it was created. The cash
  flow does not add amounts of different currencies.
- Known limit: no widget tests for month navigation, tap on the source list to edit, the archive dialog and the
  change-amount dialog of one payment; they were checked by hand only.
- Known limit: the drift schema dump (`drift_schema_vN.json`) and the migration test helpers are generated by
  hand (commands in `CLAUDE.md`); there is no `build.yaml` automation.
- Tax notes for later phases: a tax settlement refund is a one-off income; paying tax and a freelancer's VAT are
  expenses (Phase 2).

## Phase 4b - Direct import of JPEG/PDF with on-device OCR (Pro)

Goal: the user does not need Scan to import documents.

Design note: Scan JSON already carries `ocr_text`, `image_paths` and `pdf_path`, so direct import produces the
same `RawDocument` shape and then uses the same rule-engine/LLM pipeline. A new domain interface `OcrEngine`
(image/PDF bytes -> text) is added; its adapter lives in `data`. The Free version keeps Scan JSON import and
manual entry.

## Open decisions

1. **PC version technology: decided.** Every version is Flutter and the desktop version is the final phase,
   so persistence stays in Dart/drift.
2. **Final Android `applicationId` (needed before Phase 8, and before any Play upload).**
3. **Chart library (Phase 6).** Compare `fl_chart` and `syncfusion_flutter_charts`, including licensing.
4. **Model delivery on Android (Phase 7).** Bundled, side-loaded or downloaded.
   Downloading requires network access, which is otherwise out of scope.
5. **Sync design (later).** Conflict rules and the format for cloud-storage and file import.
6. **Rust packaging: decided.** Crate in `rust/` inside this repo, Budget only, not shared with Scan.
7. **OCR engine (Phase 4b).** Must support Greek; compare candidates in a short spike. It may run in Rust.
8. **How Pro is unlocked.** Mechanism not decided (must fit the no-account, fully local principle).
9. **When arm64 targets are added.** Before the first test on a physical phone (`aarch64-linux-android`, later
   `armv7`).
10. **Weekend/holiday rule: decided (implemented in 1b).** A payment that falls on a weekend or holiday moves to
    the previous working day by default. Per source the owner can choose the next working day or no shift.

## Rules for every phase

Architecture, implementation plan, source code, unit tests, integration tests, manual validation steps,
then wait for a successful compile and test run. Each phase leaves a runnable app.
