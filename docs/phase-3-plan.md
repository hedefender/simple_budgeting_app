# Phase 3 plan: JSON import (approved by the owner, 2026-10-20, with the changes below)

Status: approved. Where a section further down disagrees with "Approved changes", the approved changes win. Decisions: `docs/roadmap.md`, "Phase 3 decisions". Shared
schema: `docs/scan-json-schema.md`. Report at the end: `docs/reports/phase-3-report.md`.

Phase 2 is Done (2026-10-20). The schema dump of v4 was checked while planning: a fresh dump of the current code is
identical to `drift_schemas/drift_schema_v4.json`.

## Approved changes (owner, 2026-10-20; they override the text further down)

1. **File references:** option A (names only). Phase 3 does not copy, read or show PDF/images (A8 stands).
2. **Package `file_selector`.** Try a JSON type filter on the emulator first; if it hides files, accept every type.
   A picked file whose name does not end in `.json` (any case) gives a NEUTRAL result "Skipped: not a JSON file"
   (Παραλείφθηκε: δεν είναι αρχείο JSON), not an error. It is counted as skipped, not failed.
3. **No parser from the owner:** I define it from the schema.
4. **Parser in Rust** (`rust/src/api/scan_json.rs`, `parse_scan_json(text) -> Result<ParsedScan, ScanJsonError>`, typed
   error enum), following ADR-002 (`docs/architecture-decisions.md`). `ParsedScan.created_at` is an enum:
   `Instant { utc_ms }` when the file has an offset or `Z`; `Local { text }` (`yyyy-MM-ddTHH:mm:ss`, no zone) when it
   has none. Dart applies the device zone to `Local`. Dependencies `serde`, `serde_json`, `sha2` are approved; versions
   are chosen for Rust 1.95 and pinned with `=` in step 2. The cargokit build for x86_64 and i686 is checked and the
   codegen is run. Dart: domain interface `ScanJsonParser`, adapter `RustScanJsonParser` (thin mapping), a fake in host
   tests. The real parser is tested by `cargo test` and by the on-device integration test.
5. **Limits:** 5 MiB per file, 50 files per batch, files read one at a time. The parser strips a UTF-8 BOM (with a
   test). A sample over 5 MiB is NOT in the repo; the test creates it.
6. **Schema v5, `imports` per batch:** `id`, `imported_at`, `source` (for now `"file_picker"`), `file_count`,
   `imported_count`, `duplicate_count`, `failed_count`. `documents` gets `import_id` (FK -> `imports.id`) and
   `source_file_name`. `documents.imported_at` is removed (the batch has it). The one-time report stays as planned.
   Skipped (non-JSON) files are `file_count - imported - duplicate - failed`; no separate column.
7. **`language`** (optional BCP-47 string) in the schema and `documents.language` (nullable). `schemaVersion`
   unchanged. The legacy reader leaves it null.
8. **`documents.document_type`** (text NOT NULL, default `'unknown'`), domain enum `DocumentType`: `unknown, receipt,
   utilityBill, invoice, statement, contract, genericDocument`. No classification and no UI in Phase 3. An unknown
   value in the database reads as `unknown` (tested). The Scan JSON schema does not change.
9. **Deleting a document is in Phase 3** (reverses A5): from the detail page, with a confirmation that says that N
   linked expenses stay (their `document_id` becomes NULL). After deletion the same `documentId` can be imported
   again. Tests: use case, repository, widget.
10. **File names** (`pdfPath`, `imagePaths`) are cut to the last segment in the canonical format too, when they
    contain `/` or `\`. Used only as labels, never to build a path.
11. **Detail page:** the OCR text is shown cut to the first 20,000 characters with a button "Show all"
    (Εμφάνιση όλου).
12. **Docs only:** roadmap note that reconciles ADR-002 with the Rust/Dart table, and a line in `CLAUDE.md`.
13. **Rust rules** are recorded in the roadmap next to ADR-002: (a) Rust never opens the database; Dart passes data in
    and Rust returns a result; (b) no `unwrap`/`expect` in Rust code that processes external data; (c) every new field
    is added to the struct, the bridge and the domain with a whole-path test (sample -> parser -> database -> read).
- **A3 approved** (no offset = device local time). Scan will export `createdAt` with an offset.
- The v4 -> v5 migration test also checks `expenses.document_id` (a FK that accepts NULL) **with foreign keys
  enabled**.
- **Location of the ADR file:** the owner wrote `docs/adr/architecture-decisions.md`; the file is at
  `docs/architecture-decisions.md`. I used the real path and did not move it.

Answers to my five questions: 1 = A; 2 = `file_selector`; 3 = I define the parser; 4 = Rust; 5 = 5 MiB / 50 files.

## Architecture

New feature `lib/features/documents/{domain,data,presentation}` ("documents", not "imports": the stored thing is a
document; an import is the event that brought it in, and it is a table of this feature).

- **domain** (pure Dart):
  - Entities: `ScanDocument` (id, documentId, createdAt, ocrText, pdfName, imageNames, importedAt), `ImportRecord` (id,
    documentRowId, sourceFileName, importedAt), `ImportOutcome` (sealed: `Imported(document)`,
    `Duplicate(documentId)`, `Failed(ImportFailure)`), `ImportFailure` (enum with the reasons below), `FileImportResult`
    (file name + outcome), `ImportReport` (list of `FileImportResult`, counts).
  - Interfaces: `ScanJsonParser` (text -> `ParsedScanDocument` or a typed failure), `DocumentRepository`
    (insert if new, list, get, find by documentId, link to expense), `ImportSource` (what the use case reads: name +
    size + text; so the use case does not know about the picker).
  - Use cases: `ImportScanFiles` (takes a list of `ImportSource`; per file: size check, parse, duplicate check, store;
    a failing file never stops the others), `ListDocuments`, `GetDocument`, `GetDocumentForExpense` and
    `LinkExpenseToDocument` (see "Create expense").
  - `Clock` and `IdGenerator` come in through constructors.
- **data**: `DocumentRepositoryImpl` (drift), `RustScanJsonParser` (adapter to the bridge), `FileSelectorImportSource`
  (wraps `XFile`, reads size first and the text only when under the limit).
- **presentation**: `DocumentsPage` (list + import button), `ImportReportPage` or a bottom sheet, `DocumentDetailPage`,
  providers. Strings in ARB (en, el).
- Only `lib/app/di/service_locator.dart` knows the concrete classes, as before.

### Parsing (Rust)

`rust/src/api/scan_json.rs`: `parse_scan_json(text: String) -> Result<ParsedScan, ScanJsonError>`. `ParsedScan` holds
plain fields (`schema_version: u32`, `document_id`, `created_at` as ISO string normalised to UTC milliseconds i64 plus a
flag "had no offset", `ocr_text`, `pdf_name: Option<String>`, `image_names: Vec<String>`), and `ScanJsonError` is a typed
enum (see "Failure reasons"). It handles the canonical format, the legacy reader and all validation; the size limit is
checked in Dart before the file is read into a string (the Rust function also refuses text over the limit, as a
second guard). Rust adds `serde` and `serde_json` (needed for any JSON parser) and `sha2`. These are Rust dependencies
and are **proposed here, not added**; they need your approval together with question 4. The tests of the parser are
`cargo test` unit tests with the fixture files below; Dart tests use a fake parser, because host tests never load the
native library (CLAUDE.md).

If you choose Dart-only parsing, the same split applies (domain interface, `data` implementation), the fixtures are the
same, and the tests run in `flutter test` without the bridge.

## Failure reasons (one message each, ARB en/el, no crash)

| Reason | Cause |
| --- | --- |
| `emptyFile` | 0 bytes or only whitespace |
| `tooLarge` | over 5 MiB (reported with the limit and the file size) |
| `notUtf8` | the bytes are not valid UTF-8 |
| `invalidJson` | the text is not JSON (with the position when known) |
| `notAnObject` | valid JSON but the top level is not an object |
| `missingField(name)` | a required field is absent or null |
| `wrongType(name)` | a field has the wrong type (also a non-integer `schemaVersion`, a non-string in `imagePaths`) |
| `emptyOcrText` | `ocrText` is empty or only whitespace |
| `invalidDocumentId` | empty or longer than 128 characters after trimming |
| `invalidDate` | `createdAt` is not ISO 8601 |
| `unsupportedSchemaVersion(found, known)` | `schemaVersion` greater than 1, or less than 1 |
| `readError` | the file could not be read (permission, removed) |

## Schema v5

Step 1 of the implementation: dump v4 of the current code to a temporary folder and compare it with
`drift_schemas/drift_schema_v4.json`. If they differ, STOP and tell the owner (they are identical now).

Then `schemaVersion = 5`; `if (from < 5) { createTable(documents); createTable(imports); addColumn(expenses,
documentId); }`; new dump `drift_schema_v5.json`; regenerate `test/generated_migrations/`; retarget the existing
migration tests to v5 and add v4 -> v5. The commands are the ones in `CLAUDE.md`. No generated file is edited by hand.

**`documents`**

| Column | Type |
| --- | --- |
| `id` | text PK (UUID, local) |
| `document_id` | text NOT NULL, UNIQUE (the Scan `documentId`; the duplicate key) |
| `import_id` | text NOT NULL, FK -> `imports.id` |
| `source_file_name` | text NOT NULL (the JSON file the document came from) |
| `created_at_utc` | datetime NOT NULL (the `createdAt` instant, UTC; for a file without offset Dart applied the device zone) |
| `ocr_text` | text NOT NULL |
| `language` | text, nullable (BCP-47) |
| `document_type` | text NOT NULL, default `'unknown'` (domain enum `DocumentType`, stored by name; unknown values read as `unknown`) |
| `pdf_name` | text, nullable |
| `image_names` | text NOT NULL, a JSON array of strings (default `[]`); labels, never queried |
| `schema_version` | int NOT NULL (the `schemaVersion` the file had; legacy files are stored as 1) |
| `was_legacy` | bool NOT NULL |

No `imported_at` here: the batch in `imports` has it.

CHECK constraints: `length(trim(ocr_text)) > 0`, `length(trim(document_id)) > 0`, `schema_version >= 1`,
`language IS NULL OR length(trim(language)) > 0`. There is no CHECK on `document_type` (so an unknown value from a
newer app version cannot make a row unreadable).

**`imports`** (one row per import batch, i.e. one press of the picker)

| Column | Type |
| --- | --- |
| `id` | text PK (UUID) |
| `imported_at` | datetime NOT NULL |
| `source` | text NOT NULL (`"file_picker"` for now) |
| `file_count` | int NOT NULL (files picked) |
| `imported_count` | int NOT NULL |
| `duplicate_count` | int NOT NULL |
| `failed_count` | int NOT NULL |

CHECKs: all counts `>= 0`, and `imported_count + duplicate_count + failed_count <= file_count`. The row is inserted
at the start of the batch (counts 0) and updated at the end, so documents can point to it; a batch that crashes in the
middle keeps counts that are too low (accepted). Per-file failures are not stored: they live in the one-time report.
Deleting a document does not delete or change its batch row (history).

**`expenses.document_id`**: a nullable text column, FK -> `documents.id`, `ON DELETE SET NULL`. This is an additive
migration (`addColumn`; a nullable column needs no default). Deleting a document is in Phase 3 (decision 9). SQLite enforces foreign keys only when
`PRAGMA foreign_keys = ON`; step 4 checks that `beforeOpen` turns it on (and adds it if not, with a test), and the
migration test runs with it enabled. One document can have several expenses (the user may split it); an
expense has at most one document. The expense stays valid without the document.

This column is the only change to an existing table. If you prefer a link table instead (`document_expenses`), say
so; the column is simpler and enough for "one expense, one document".

## Navigation

The NavigationBar has three tabs (Home, Income, Expenses). A material `NavigationBar` supports up to five. Proposal:
**a fourth tab "Documents"** (`Έγγραφα`, icon `description_outlined`) that holds the list and the import button.

- Import is the main action of the page: a FAB "Import" (`Εισαγωγή`), consistent with Income and Expenses. It opens the
  file picker with multiple selection, so Single Scan and Multi Scan are the same gesture.
- Why a tab and not Settings: documents are data the user returns to (list, detail, create expense); Settings is for
  configuration. Why not only a button in Expenses: a document exists before and without an expense.
- Cost: only one free slot remains in the bar (five maximum). Phase 6 (dashboards) will probably need it. When that
  happens, the fifth tab can be Dashboards and Settings stays reachable from Home. I flag this now so that you can
  object.
- Hero tags and the FAB clearance: the new page uses `fabListBottomPadding` and its own `heroTag`, as learned in Phase 2.

## Screens

**DocumentsPage**: list, newest `createdAt` first. A row shows the first useful line of the OCR text (the first
non-empty line, one line, ellipsis), the `createdAt` date, an icon if it is legacy, and a small chip "Expense linked"
(`Συνδεδεμένο έξοδο`) when an expense points to it. Empty state: a short explanation and the Import button. A search
field is NOT in Phase 3.

**Import flow**: the FAB opens the picker (JSON files, multiple). The page shows a progress indicator while files are
processed. When it ends, an **import report** opens (a full page, so a long list is readable): a summary line (`3
imported, 1 already imported, 2 failed`) and one row per file with an icon, the file name and the result: imported
(with the first line of the text), "Already imported" (duplicate) or the error message with the reason. Files are listed in the order
they were picked. The report is shown once; it is not stored (the `imports` table is the history of successes).
If the user cancels the picker, nothing happens and nothing is shown.

**DocumentDetailPage**: the date and time (local), the document id (selectable, small), the source (file name of the
import and the import date), "Legacy format" note when relevant, the file references ("PDF: name", "Images: n files": names
only; the note "Files are not stored in the app" until the owner decides question 1), the full OCR text (selectable,
scrollable, monospace is not needed), and the button **Create expense** (`Δημιουργία εξόδου`). If an expense is already
linked: the list of linked expenses (tap opens the expense) and the button remains, so the user can add another.

## Create expense from a document

The button opens the existing `ExpenseFormPage` with pre-filled fields and a `documentId` parameter:

- **Date**: the local calendar day of `createdAt` (converted from UTC with the device time zone; the same rule as any
  instant shown as a day). The existing balance-start warning of Phase 2 works unchanged on that date.
- **Description**: the first non-empty line of the OCR text, trimmed, cut to 80 characters. The user can edit it.
- **Amount and category are NOT pre-filled.** No text analysis in Phase 3 (the rule engine is Phase 4). The category keeps its
  default.
- A line above the form shows "From document <date>" with a link back, so it is clear where the expense comes from.
- On save, the expense is stored with `document_id`. Editing the expense later keeps the link. A link cannot be removed
  in Phase 3 (assumption A6; removing is a small addition if you want it).
- The expense form's domain validation does not change. `CreateExpense` receives an optional `documentId`; the
  repository checks that the document exists (a failure is a typed error, not a crash).

## Implementation steps

After every step: `flutter analyze`, `flutter test`, `cargo test`. `dart format` only on the files I changed, never on a
folder. No commit. On-device tests are not run without your permission.

1. **Schema check.** Dump v4 of the current code to a temporary folder and compare it with the committed dump. Stop if they differ. (Done while planning; repeated here.)
2. **Dependencies** (only the approved ones): `file_selector` (+ the Android implementation arrives as a dependency of
   the package), and the Rust crates if parsing is in Rust.
3. **Rust parser** (or the Dart parser): schema v1, legacy reader, validation, typed errors; fixtures; `cargo test`.
   Then `flutter_rust_bridge_codegen generate`.
4. **Schema v5**: tables, `expenses.document_id`, migration, dump, generated helpers, migration tests (v4 -> v5, with
   v4 data kept, CHECK constraints, FK behaviour).
5. **Domain**: entities, interfaces, `ImportScanFiles` and the other use cases, with fakes; unit tests.
6. **Data**: `DocumentRepositoryImpl`, the parser adapter, the picker adapter; repository tests on in-memory drift.
7. **DI and providers**: service locator, fakes in `test/support`, a documents harness.
8. **Presentation: list, import, report, detail**; ARB en/el; widget tests.
9. **Create expense from a document**: form parameters, link, widget tests.
10. **Navigation**: the fourth tab; update the existing shell tests.
11. **Docs**: `docs/manual-validation.md` section 13, `docs/architecture.md` (Documents section), roadmap, `docs/reports/phase-3-report.md`
    with the list of files to commit (`drift_schemas/drift_schema_v5.json`, `test/generated_migrations/schema_v5.dart`,
    `schema.dart`, `app_database.g.dart`, the three `app_localizations*.dart`, the bridge outputs if Rust is used).
12. **Integration test** (written, not run without permission): import a JSON from the test assets, see it in the list.

## Tests

Fixtures: `test/fixtures/scan_json/` (and the same files for `cargo test` in `rust/tests/fixtures/`, or one shared
folder; one copy is read by both) with: `valid_v1_full.json`, `valid_v1_minimal.json` (no paths), `valid_v1_unknown_fields.json`,
`legacy_full.json`, `legacy_no_paths.json`, `legacy_absolute_paths.json`, and one file per malformed case.

- **Parser (cargo test, or `flutter test` for a Dart parser):**
  - single canonical document, full and minimal; unknown fields ignored; `imagePaths` null / absent / empty;
  - **legacy reader**: fields mapped; the id is stable (the same file twice gives the same id; a different `created` or
    text gives a different id); absolute paths cut to names; a legacy file that is also malformed fails with the same reasons;
  - **malformed**, one test each: invalid JSON, empty file, whitespace-only file, not UTF-8, top level an array / a
    string, missing `documentId` / `createdAt` / `ocrText` / `schemaVersion`, wrong types (`ocrText` number, `imagePaths`
    string, an item of `imagePaths` a number, `schemaVersion` string or 1.5), empty and whitespace `ocrText`, empty and
    129-character `documentId`, bad dates, `schemaVersion` 2 and 0 and -1, a file over the size limit and one exactly at it;
  - `createdAt` with `Z`, with `+03:00`, and without offset.
- **`ImportScanFiles` (unit, fake parser and fake repository):**
  - single file; several files (Multi Scan); **a failing file in the middle does not stop the next ones** and the
    order of the results is the order of the input;
  - **duplicate**: the second import of the same `documentId` returns `Duplicate`, stores nothing, creates no second
    `imports` row, and the first document is not changed; a duplicate inside the same batch (two files with the same
    id) imports the first and reports the second;
  - every failure reason is mapped to a result and no exception escapes (including a repository that throws);
  - an empty selection and more than 50 files.
- **Repository (in-memory drift):** insert, unique `document_id`, list order, the CHECK constraints reject empty text
  (with explicit NULL handling, as in Phase 2), `imports` row per success, FK from expenses (a link to a missing
  document fails; `ON DELETE SET NULL` keeps the expense).
- **Migration**: v4 -> v5 keeps expenses, categories and income; `expenses.document_id` is null for old rows; the new
  tables exist; the schema equals the v5 dump. The earlier migration tests are retargeted to v5.
- **Widget:** Documents tab shows the empty state; the list after an import; the report page for imported / duplicate /
  error rows (a fake picker returns several files); cancelling the picker; the detail page (text, references, legacy
  note); "Create expense" opens the form with the date and description filled and no amount; saving links the expense;
  the linked chip and the linked expense list; the balance-start warning appears on the pre-filled date when relevant; Greek and English
  strings; the FAB clearance on the new list; the navigation shell with four tabs.
- **Integration (`integration_test/document_import_test.dart`)**: a canonical JSON from assets goes through the real
  database and the real parser; it appears in the list; importing it again reports a duplicate. **Written, and not run
  without your permission.**

## Manual validation plan (new section 13 of `docs/manual-validation.md`)

The picker and Android storage cannot be fully tested on the host, so section 13 is checked by hand:

1. Put the sample files on the emulator or phone (`docs/samples/scan-json/`, created in step 11: a valid v1 file, a
   legacy file and the malformed ones). Open the fourth tab "Έγγραφα": the empty state is shown.
2. Single import: pick `valid_v1_full.json`; the report says `1 imported`; the document is in the list.
3. Open it: the date, the text, the file names; "Δημιουργία εξόδου" opens the form with the date and a description and
   no amount. Fill amount and category, save; the expense appears in the Expenses tab and the document shows the link.
4. Import the same file again: "Ήδη εισαγμένο", no second document.
5. Multi import: pick five files at once (two valid, one legacy, one malformed, one empty). The report lists each file
   with its own result; the valid ones are imported although a failing one is in the middle.
6. Each malformed sample gives its own readable message (invalid JSON, wrong type, empty text, `schemaVersion` 2, empty
   file, a file over 5 MiB); the app does not close.
7. Legacy file: imported, marked "Legacy"; importing it twice gives a duplicate.
8. Date check: a document created late in the evening near midnight in another offset shows the right local day in the
   form.
9. Balance start: the expense from a document dated before the balance start shows the Phase 2 warning.
10. Force-close and reopen: documents, links and expenses are still there. Upgrade from the Phase 2 build keeps all data.
11. Privacy: airplane mode on; everything above works the same.

## Assumptions (tell me which ones you reject)

- A1. Feature name `documents`; tab label "Έγγραφα" / "Documents".
- A2. Parsing is in Rust (the roadmap's table); the size limit is checked in Dart.
- A3. A `createdAt` without an offset is read as device local time. (Old Scan files probably have none; treating them as
  UTC would shift the day for users in Greece by up to three hours.)
- A4. The expense pre-fill date is the local day of `createdAt`.
- A5. (Reversed by decision 9) A document is never overwritten or edited; it CAN be deleted.
- A6. The expense-document link cannot be removed in Phase 3.
- A7. (Changed by decision 6) `imports` has one row per batch with counts. Failure details live only in the one-time report.
- A8. PDF and image files are not read, copied or displayed in Phase 3 (question 1).
- A9. No analysis of the OCR text: no amount, no vendor, no category detection. The `vendor` column of expenses
  (roadmap, Phase 2 notes) is NOT added in Phase 3 either, because nothing fills it before Phase 4.
- A10. Limits: 5 MiB per file, 50 files per import, `documentId` at most 128 characters.
- A11. Nothing is added to Android permissions: the picker uses the system file chooser (no storage permission).
- A12. Documents appear in no sum, no balance and no cash flow. Only expenses do.

## File picking: the package proposal

**`file_selector`** (flutter.dev, the Flutter team): `openFiles(acceptedTypeGroups: ...)` returns `XFile`s with
`name`, `length()` and `readAsString()`/`readAsBytes()`. It supports multiple selection, Android (through the system
chooser, no storage permission), iOS, and the Windows/macOS/Linux desktop that the final phase needs. It is small, has
no UI of its own and is easy to fake (the data adapter wraps it, the tests never call it).

Alternative: `file_picker` (community package, very common): more options (picking folders, sorting), but it copies
files to the cache by default and has a larger API surface and many more platform dependencies. Not needed now.

Possible limit to verify on the emulator, before relying on it: the JSON MIME type filter on Android (some file
providers label `.json` as `application/octet-stream`). If so, the type group accepts every file and validation rejects
non-JSON content. I have not checked this yet.

Either way, nothing is added until you approve.

## Additions to the steps and tests (from the approved changes)

Domain and screens:

- New use case `DeleteDocument` (and `CountLinkedExpenses` for the confirmation text). The detail page has a delete
  action with a confirmation that names the number N of linked expenses that stay.
- `ImportOutcome` gets a fourth case `Skipped` (not a `.json` file). The report shows skipped rows in a neutral style and
  the summary line counts them separately.
- `ScanDocument` gets `language`, `documentType` (`DocumentType`), `sourceFileName`, `importId`; it loses `importedAt`.
  The import batch (`ImportBatch`: id, importedAt, source, counts) is its own small entity.
- `ParsedScan` mirrors the Rust struct; `CreatedAt` is a sealed class (`InstantCreatedAt`, `LocalCreatedAt`). The use
  case turns `LocalCreatedAt` into UTC with the device zone through an injected function (so tests control the zone).
- The detail page cuts the OCR text at 20,000 characters and offers "Show all".

Extra tests:

- Rust: BOM removed; `language` present, absent, empty string, null; `pdfPath`/`imagePaths` with `/` and `\` cut to the last
  segment, and a value like `folder/` rejected; `createdAt` as `Instant` and `Local`; no `unwrap`/`expect` on external
  data (checked by a grep in review and by a clippy lint `unwrap_used`/`expect_used` on the module if it works);
  a 5 MiB + 1 byte text built inside the test is refused, 5 MiB exactly is accepted (no big fixture file in the repo).
- `ImportScanFiles`: a `.json` check that is case-insensitive (`A.JSON`), a PDF in the same selection gives `Skipped`
  and does not count as failed; 51 files are refused with a clear message before any is read; files are read one at a time
  (the fake source records the order and that two reads never overlap).
- Repository: `document_type` unknown string reads as `DocumentType.unknown`; `language` null and set; `import_id` FK;
  batch counts; delete document -> linked expenses get `document_id = NULL` and stay; the same `documentId` imports
  again after deletion; the `imports` CHECKs.
- Migration v4 -> v5 with foreign keys enabled: an old expense has `document_id` NULL (the FK accepts NULL); an expense
  linked to a document keeps its link after deleting nothing; deleting the document sets it to NULL.
- Whole-path tests (Rust rule c): a sample JSON -> the real parser (integration test on the device; in host tests the
  Dart side uses fixtures through the fake) -> database -> read back, for every field including `language` and
  `documentType`.
- Widget: delete confirmation with N; "Show all"; skipped row in the report.

Additional step 3b: check that cargokit builds `x86_64-linux-android` and `i686-linux-android` with the new crates
(`flutter build apk --debug --target-platform android-x64` as a build check; the Gradle ABI limit stays as it is), and
pin the crate versions with `=`.
