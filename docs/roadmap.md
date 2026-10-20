# Roadmap

## Current position

| Step | Status |
| --- | --- |
| Toolchain: Flutter 3.47.7, Dart 3.13.5, Android SDK, RustRover plugins, smoke test on a device | Done (2026-10-17) |
| Rust bridge smoke test (throwaway `flutter_rust_bridge_codegen create` project) | Done (2026-10-17) |
| Phase 0a: Flutter-only foundation (delivered zip) analyzes, tests and runs | Done (2026-10-17) |
| Phase 0b: add the Rust crate with a trivial function behind a domain interface (crate in `rust/` inside this repo) | Done (2026-10-18) |
| Phase 1a: income data model, manual entry, basic cash flow | Done (2026-10-19) |
| Phase 1b: full schedule engine | Done (2026-10-19) |
| Phase 1c: currency handling (primary currency, per-source currency, no hidden data) | Done (2026-10-19) |
| Phase 1d: worker profiles and extra payments | Done (2026-10-19) |
| Phase 2: expenses | Done (2026-10-20; the owner's manual check of `docs/manual-validation.md` section 12 passed). Plan: `docs/phase-2-plan.md`. Report: `docs/reports/phase-2-report.md` |
| Phase 3: JSON import | Done (2026-10-21; the owner's manual check of section 13 passed and `integration_test/document_import_test.dart` passes on the Testing_Phone emulator). Decisions: "Phase 3 decisions" below. Schema: `docs/scan-json-schema.md`. Plan: `docs/phase-3-plan.md`. Report: `docs/reports/phase-3-report.md` |
| Phase 2b and Phase 4 onward | Not started (notes collected for Phase 4: `docs/phase-4-notes.md`) |

Known issue — Phase 3: a failure to load the native library is not shown as a clear error. `RustScanJsonParser` catches only
`ScanJsonError`; `ImportScanFiles` turns every other error into `Failed(unexpected)` and keeps no detail. If the Rust library is
not loaded, every file of an import shows as "unexpected" and the real cause (`StateError: flutter_rust_bridge has not been
initialized`) is lost. It should reach the user as a clear error. Not fixed in Phase 3. Seen in the first run of
`document_import_test.dart`, which did not load the library (a test bug, fixed in the test only).

Known issue — Phase 3: the picker does not filter to `.json` on Android. Seen in the owner's manual check (2026-10-21): in
Documents → Import the Android file chooser shows a PDF as selectable although `jsonOnly: true` should grey it out or hide it;
the import reports the PDF as skipped, so it never becomes a document. From the code: `FileSelectorImportFilePicker.pick()`
(`lib/features/documents/data/file_selector_import.dart`) calls `openFiles(acceptedTypeGroups: ...)`. With `jsonOnly: true` it
passes one `XTypeGroup(label: 'JSON', extensions: ['json'], mimeTypes: ['application/json'])`; with the default
(`jsonOnly: false`, the one the app uses) it passes an empty list. Not fixed; investigation in a later phase, low priority.

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

Phase 1b note: schedule engine with weekly, several per month, Nth working day, shift rules and an offline Greek
holiday calendar (docs/holidays.md); drift schema v3 adds income_entries.actual_date; the form, the cash flow and the
freeze-on-edit use actual dates. `flutter analyze` is clean, `flutter test` passes (266/266), `cargo test` passes
(2/2), the integration tests pass on the emulator, and the owner's manual check passes (weekly, a payment shifted to
another month, Nth working day, several payments a month). Report: docs/reports/phase-1b-report.md.
Problem found on the emulator during that check: after the device region changed (el_GR/EUR to en_US/USD) the Income
page showed 0 and "No payments this month" while the sources were in EUR, because the cash flow filtered by the
device currency. Phase 1c fixes this.

Phase 1a note: `flutter analyze` is clean, `flutter test` passes (147/147), `cargo test` passes (2/2), the
integration tests pass on the emulator, and the owner's manual check of steps 1-9 passes. Details:
`docs/reports/phase-1a-report.md`.

Phase 1c note (Done; the owner's manual check of `docs/manual-validation.md` section 10 was done on 2026-10-19): `primary_currency` in `app_settings`
(no schema change), Settings page, currency chosen when a source is created, balance per currency, Income page with
one cash flow block per currency and all payments listed. No conversion. Report: docs/reports/phase-1c-report.md.

Phase 1d note (Done; the owner's manual check of `docs/manual-validation.md` section 11 passed on 2026-10-19):
first-run setup wizard, `Yearly` schedule (fixed date or Orthodox Easter offset), `IncomeType.extraPayment`, Greek
private-sector preset pack shown as "Suggested" with empty amounts. No schema change (still v3). `flutter analyze` is
clean, `flutter test` passes (330/330), `cargo test` passes (2/2), the integration tests pass on the emulator (4/4).
Report: docs/reports/phase-1d-report.md.

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
| 1c | Currency handling | `primary_currency` setting, minimal Settings page, currency chosen per source at creation, anchors per currency, Income page never hides data (per-currency cash flow blocks, all payments listed with their currency). No conversion | - |
| 1d | Income: first-run wizard and extra payments | First-run wizard (profile: employee, freelancer, side-hustle) that creates income sources with the existing `IncomeType`; extra payments as separate sources with a new `Yearly` schedule and `IncomeType.extraPayment`; Greek preset pack as a data file, shown as "Suggested" with an empty amount; no schema change (research: `docs/extra-payments.md`) | - |
| 2 | Expenses | Manual entry (one total, one category, optional original amount/currency and VAT note, pending state), editing, deleting, history with month and category filter, categories as data, expenses in the cash flow (schema v4; see "Phase 2 decisions") | - |
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
- Currency (replaced in Phase 1c, see "Phase 1c decisions"): the old limit "the cash flow filters by the device
  currency" is gone.
- Known limit: no widget tests for month navigation, tap on the source list to edit, the archive dialog and the
  change-amount dialog of one payment; they were checked by hand only.
- Known limit: the drift schema dump (`drift_schema_vN.json`) and the migration test helpers are generated by
  hand (commands in `CLAUDE.md`); there is no `build.yaml` automation.
- Known limit (1b): payments that were never frozen are computed from the holiday calendar. If the calendar is
  corrected later, their actual date can change. Stored decisions key on the nominal date. Closing a month
  (Phase 2b) will freeze them. Details and sources: `docs/holidays.md`.
- Tax notes for later phases: a tax settlement refund is a one-off income; paying tax and a freelancer's VAT are
  expenses (Phase 2).

## Phase 1c decisions (implemented; report: docs/reports/phase-1c-report.md)

- Language and number format follow the device. The currency belongs to the data.
- Setting `primary_currency` in `app_settings`. Default: the device currency on first start; for an existing
  install, the currency of the existing sources if there are any. It never changes by itself when the device
  changes. The owner changes it on a minimal Settings page.
- A source gets its currency at creation (default: the primary currency) and it cannot change afterwards (a new
  currency means a new source). A balance anchor is set per currency.
- The Income page never hides data: the payment list shows every payment with its currency, and the cash flow card
  shows one block (opening balance, received, expected, projected closing balance) for each currency that appears,
  primary first.
- No currency conversion in this phase. Amounts of different currencies are never added.
- Schedule summary: Greek "5η εργάσιμη" instead of "εργάσιμη 5", and the shift rule is shown when it is not "none".

## Phase 1d decisions (owner, 2026-10-19; implemented, report: docs/reports/phase-1d-report.md)

- A "profile" is a first-run wizard that creates income sources with the existing `IncomeType`. One profile per
  installation.
- Extra payments are separate sources with a new schedule type `Yearly` (a fixed month and day, or an offset from
  Orthodox Easter, plus a shift rule) and a new `IncomeType.extraPayment`, added at the END of the enum. The type is
  stored as text (`IncomeType.name`), so it needs no migration.
- **No schema change (no v4).** No "unconfirmed" state is stored, because it would count in the cash flow. The wizard
  shows the preset lines with a "Suggested" label and an EMPTY amount field. A source is created only for the lines
  the user ticks and gives an amount. After that they are ordinary sources. No `preset_key` or `confirmed_at` column.
  If the wizard runs again from Settings, it warns when a source with the same name already exists.
- Amounts are fixed, net and typed by the user. No link to the salary and no tax calculation. Helper text under the
  empty field: Christmas "indicatively up to the net salary", Easter "up to half of it".
- Dates: Christmas bonus 21 December, Easter bonus Holy Wednesday (Orthodox Easter - 4 days), both with the shift
  "previous working day".
- Leave allowance is optional: off by default, and the user gives the date.
- Part-time and intermittent work: manual amounts only, no calculation.
- No preset for the public sector. The wizard says the suggestions are for the private sector.
- A button "Add another yearly payment" covers a 13th or 14th salary and similar.
- `lastVerified` of the preset pack is shown in the wizard only.
- The Greek preset pack is a data file with the date of its last verification.
- Database protection and export (open decision #15) does NOT belong to 1d; it moves to after Phase 2.
- Research on the rules: `docs/extra-payments.md` (read 2026-10-19). Finding that affects the design: the Easter
  bonus is due on Holy Wednesday, which is relative to Orthodox Easter, so a fixed month and day is not enough.

## Phase 2 decisions (owner, 2026-10-19; Done 2026-10-20; plan: docs/phase-2-plan.md)

Notes added with the approval of the plan:

- **Refunds** are entered as income "Other" for now. Reconsider in Phase 6.
- **`vendor`**: a nullable column of `expenses`, added (additive migration) when the Scan JSON arrives (Phase 3/4).
- The "Other..." account currency in the expense form uses the same ISO code validation as the Settings page.


1. **One expense = one total and one category.** No per-product lines in Phase 2. Later (local LLM, Phase 7) optional
   lines are added in a NEW table (additive migration) whose sum equals the total; the category of the expense stays
   as the default. The Phase 2 model must allow this (the expense id is a UUID that a future lines table can point to;
   nothing in `expenses` may assume that there are no lines).
2. **The total is what left the user's pocket.** An optional, informational field "of which VAT/taxes" (an amount,
   part of the total, added to no sum). It is shown in a collapsible section of the form. There is no setting for it.
3. **Currency.** An expense stores its amount in the currency of the account that was charged (default: the primary
   currency; the choice offers the currencies that exist in the app). It may also store an original amount and
   currency (for example 24.50 GBP), informational only. No currency conversion and no exchange rates. Open decision
   #11 does not concern expenses.
4. **Pending expense.** If the user gave only the original amount and currency and not the amount in the account
   currency, the expense is saved as "awaiting amount". It is always visible in the list with a marker, does not count
   in the totals or the balance, and is completed when the user enters the amount that was charged (as in the bank's
   message or movement). The form says so explicitly. It is never hidden silently. Every expense has either an account
   amount, or an original amount with a currency.
5. **Categories in Phase 2.** A fixed catalogue with stable keys and names from the ARB files: Energy, Water,
   Telecommunications, Food, Fuel/Transport, Health, Insurance, Other. Chosen by hand. The catalogue is DATA (a
   `categories` table with keys), not an enum in the code, so later additions (medical costs, medicines, pets, ...)
   need no schema change. Choosing the category from the document type (ΔΕΗ/Protergia -> Energy, petrol station ->
   Fuel, supermarket/kiosk -> Food) belongs to Phase 4/5. The user's own categories come in Phase 5.
6. **Balance.** Registered expenses are subtracted from the balance and from the projected closing balance of the
   month, per account currency, inside the existing cash flow block (a new line "Expenses"). Only expenses dated AFTER
   the date of the balance anchor count, because earlier ones are already inside it. Same-day semantics follow the
   anchor rule already in force for income: the anchor is the balance at the END of its day, so an expense dated ON the
   anchor day is part of the anchor and is not subtracted again. Pending expenses never count.
7. **History.** The list shows all expenses with a month selector (as in Income), a category filter, and a total per
   currency. Edit and delete (with confirmation). No export (CSV/JSON is open decision #15, after Phase 2).
- **Balance start (added after the first emulator check).** Per currency, the balance start is the date of the oldest
  balance anchor; without an anchor, the start date of the oldest income source (archived too); without either there
  is no start and no warning. Before the start the app does not know the balance. A month that ends before the start
  shows "-" for the opening and closing balance and the note "The balance starts on <date>"; the income and expense
  lines stay visible. From the start month on, the calculation is unchanged. Expenses dated before the start stay in
  the history and the totals but never change a balance, also without an anchor. The expense form warns (not
  blocking, computed every time, never stored) when the date is too early: with a start taken from an anchor that
  means on or before the anchor day (the anchor day is inside the anchor) and the button proposes the next day; with a
  start taken from a source it means before that day and the button proposes that day.

## Phase 3 decisions (owner, 2026-10-20; plan approved: docs/phase-3-plan.md; implemented, report: docs/reports/phase-3-report.md)

The shared schema is described in `docs/scan-json-schema.md`.

1. **Canonical schema v1 (camelCase):** `schemaVersion` (int), `documentId` (string, unique), `createdAt` (ISO 8601),
   `ocrText` (string), `pdfPath` (string, optional), `imagePaths` (list of strings, optional). Unknown extra fields are
   ignored. A `schemaVersion` greater than the known one gives a clear error and nothing is imported.
2. **Legacy format** (`version`, `created`, `ocr_text`, `image_paths`, `pdf_path`): read by a small converter (the
   legacy reader), never written. It has no `documentId`, so the converter builds a stable id from the content (a hash
   of `created` and `ocr_text`).
3. **Importing the same `documentId` twice** creates no duplicate; the user is told.
4. **Phase 3 stores documents** (tables `documents` and `imports`) **and the OCR text. It does NOT analyse the text**
   (rule engine = Phase 4, LLM = Phase 7). The user creates an expense from a document with pre-filled fields (date
   from `createdAt`, description), and the expense is linked to the document.
5. **One or many JSON files at once** (Single Scan, Multi Scan). A failing file does not stop the others; the user sees
   a report per file (imported, duplicate, error with the reason).
6. **Malformed input** (invalid JSON, wrong types, empty `ocrText`, unsupported `schemaVersion`, a file over the size
   limit, an empty file) gives understandable messages and never crashes.
7. **Privacy:** nothing is sent over the network.

Changes and answers given with the approval of the plan (2026-10-20); details in `docs/phase-3-plan.md`, "Approved changes":

- **File references:** option A, file names only; Phase 3 does not copy, read or show PDF/images. Names are cut to the
  last segment (`/` or `\`) also in the canonical format, and are only labels. Consequences for Phase 8 are in
  `docs/scan-json-schema.md`.
- **File picking:** `file_selector`. A JSON filter is tried on the emulator first; if it hides files, every type is
  accepted. A file that is not `.json` is "Skipped: not a JSON file", a neutral result, not an error.
- **Parser in Rust** (`rust/src/api/scan_json.rs`, ADR-002), typed errors; `createdAt` comes back as a UTC instant
  (file with offset or `Z`) or as local time without zone plus the flag "no offset"; Dart applies the device zone. Rust
  crates `serde`, `serde_json`, `sha2` approved (versions pinned). Scan will write `createdAt` with an offset.
- **Limits:** 5 MiB per file, 50 files per batch, one file read at a time, UTF-8 BOM removed. A sample over 5 MiB is
  created inside the test.
- **Schema v5:** `imports` is one row per batch (counts, source `file_picker`); `documents` has `import_id`,
  `source_file_name`, `language`, `document_type` (default `unknown`, enum `DocumentType`, no UI) and no `imported_at`;
  `expenses.document_id` (nullable FK, `ON DELETE SET NULL`).
- **Optional `language`** (BCP-47) added to the schema without changing `schemaVersion`.
- **Deleting a document is in Phase 3** (confirmation names the N linked expenses that stay; the same `documentId`
  can be imported again). The detail page shows the first 20,000 characters of the OCR text with "Show all".

Implementation notes (2026-10-20), where the build differs from the plan text:

- The types that cross the bridge are flat: a plain enum `ScanJsonErrorKind` plus detail fields, and `created_at_utc_ms` /
  `created_at_local` instead of an enum with data. The code generator needs the `freezed` package for a data-carrying
  enum, and no new dependency was approved for it.
- The file chooser has no type filter in this build (a filter can hide `.json` files that a provider labels with
  another type). Trying the JSON-only filter on the emulator is step 2 of the manual validation; the switch is
  `FileSelectorImportFilePicker(jsonOnly: true)`.
- `file_selector` ^1.1.0 and, in `rust/Cargo.toml`, `serde =1.0.229`, `serde_json =1.0.154`, `sha2 =0.11.1` (pinned).

## ADR-002 and the Rust/Dart division (owner's proposal, 2026-10-20)

ADR-002 (`docs/architecture-decisions.md`) says "Rust for Business Logic: Rust handles parsing and analytics". Read together
with the table above, it means:

- **In Rust (ADR-002):** the rule engine, categorisation, parsing of import files (Scan JSON now), statistics and
  prediction.
- **In Dart, behind a domain interface:** the income engine (`ScheduleEngine`, payments, holidays) and the cash flow.
  They may move to Rust later without changing the callers.
- **"Analytics Engine" in the brainstorming** means aggregated data prepared by the domain, which charts only display
  (Phase 6). It is not a separate engine.

Points where the documents do not agree (noted, NOT decided; the owner decides):

1. ADR-002's title says "Business Logic" and its reason says "Shared compute layer across platforms", which read
   broader than the list above; the income engine and the cash flow are business logic that stays in Dart.
   `CLAUDE.md` already says income schedule logic stays in Dart.
2. ADR-002 says Rust handles "analytics", while Phase 6 in the table above computes dashboards with drift aggregate queries
   in Dart and uses Rust only for Phase 9 (prediction, anomalies). Does Phase 6 aggregation stay in Dart (my reading)?
3. The "Division" table has a line for Phase 6 and for the "shared compute layer" that the ADR names; no phase moves
   the cash flow to Rust. If "later" has to be planned, it needs a phase.

## Rules for the Rust code (owner, 2026-10-20; they apply from Phase 3)

a. Rust never opens the database. Dart passes the data in and Rust returns a result.
b. No `unwrap` or `expect` in Rust code that processes external data (files, JSON, OCR text). Errors are typed values.
c. Every new field is added to the Rust struct, the bridge and the domain, with a test of the whole path: sample ->
   parser -> database -> read back.

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
11. **Currency conversion (Phase 6 or later; NOT Phase 2, see "Phase 2 decisions" #3).** Open when it happens. Principle: no infrastructure of our own,
    everything local. Using the internet is allowed for time, exchange rates and other third-party services, as
    long as no personal data is sent. Conversion: manual exchange rates are always available (offline), plus an
    optional automatic download from a public source chosen later. The result is a total in the primary currency.
    Phase 1c does not convert.
12. **Shared Scan/Budget JSON schema (before Phase 3).** Decided by the owner on 2026-10-20: see "Phase 3 decisions"
    and `docs/scan-json-schema.md`. Scan has to be changed to write schema v1; the file references are open (#16).
13. **Several profiles per household.** Open. Is it one database file per profile?
14. **OCR engine and Greek (Phase 4b, see #7).** Open. ML Kit does not list Greek on its official list of
    supported languages, so it needs a test with real documents before it is a candidate.
15. **Database protection and export (after Phase 2; not in 1d).** Direction from the owner: the copy belongs to the user and
    lives where the user chooses; encryption, if any, is the business of the cloud provider the user picks. The
    app produces the database file and can export to a spreadsheet. The app should also offer to restore a copy
    when it starts on an empty database (accidental uninstall or reinstall). Open: file format of the copy,
    spreadsheet format (CSV or XLSX), when the copy is made, and how the restore offer works.

16. **File references in Scan JSON (`pdfPath`, `imagePaths`): decided (2026-10-20), option A, names only.** How the
    files travel (picker, shared folder, intents) is decided in Phase 8. See `docs/scan-json-schema.md`.
17. **File picking package for Phase 3: decided (2026-10-20), `file_selector`.**

## Rules for every phase

Architecture, implementation plan, source code, unit tests, integration tests, manual validation steps,
then wait for a successful compile and test run. Each phase leaves a runnable app.
