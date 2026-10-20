# Phase 3 plan: JSON import (waiting for the owner's approval)

Status: PLAN ONLY. No code is written before approval. Decisions: `docs/roadmap.md`, "Phase 3 decisions". Shared
schema: `docs/scan-json-schema.md`. Report at the end: `docs/reports/phase-3-report.md`.

Phase 2 is Done (2026-10-20). The schema dump of v4 was checked while planning: a fresh dump of the current code is
identical to `drift_schemas/drift_schema_v4.json`.

## Questions for the owner (need an answer before or with the approval)

1. **File references** (`pdfPath`, `imagePaths`): do you agree with option A of `docs/scan-json-schema.md` (plain file
   names, resolved against the files delivered together; Phase 3 stores the names only)? This is also open decision #16.
2. **Package for picking files: `file_selector`** (published by flutter.dev) is proposed. I add nothing to `pubspec.yaml`
   until you approve. See "File picking" below, including the alternative.
3. **Do you have your working Scan JSON parser** (the roadmap says "reuse the owner's working parser")? If yes, send
   it or its location, and I adapt it to schema v1. If not, I write the parser from scratch from the schema document.
4. **Where does parsing live: Rust or Dart?** The roadmap puts "parse and validate Scan JSON" in Rust. I propose it
   (below), with the cost that it needs one new Rust dependency, `sha2`, for the legacy id, plus the bridge codegen.
   A Dart-only parser is smaller (the `crypto` package, from dart.dev, would give the hash). Which one?
5. **Size limit: 5 MiB per file** and **at most 50 files per import**. OK? (An OCR page is a few KB, so 5 MiB is very
   generous and still safe in memory.)

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
| `created_at_utc` | datetime NOT NULL (the `createdAt` instant, UTC) |
| `ocr_text` | text NOT NULL |
| `pdf_name` | text, nullable |
| `image_names` | text NOT NULL, a JSON array of strings (default `[]`); they are references, never queried |
| `schema_version` | int NOT NULL (the `schemaVersion` the file had; legacy files are stored as 1) |
| `was_legacy` | bool NOT NULL |
| `imported_at` | datetime NOT NULL |

CHECK constraints: `length(trim(ocr_text)) > 0`, `length(trim(document_id)) > 0`, `schema_version >= 1`.

**`imports`** (one row per import event of one file that created a document; the history of where documents came from)

| Column | Type |
| --- | --- |
| `id` | text PK (UUID) |
| `document_row_id` | text NOT NULL, FK -> `documents.id` (ON DELETE CASCADE) |
| `source_file_name` | text NOT NULL |
| `imported_at` | datetime NOT NULL |

Only successful imports and nothing else are stored (a duplicate or an error creates no row, because the user sees
it in the report). The initial description of the tables (`documents`, `imports`) is not in the repository's docs;
these columns are my proposal and are part of what you approve.

**`expenses.document_id`**: a nullable text column, FK -> `documents.id`, `ON DELETE SET NULL`. This is an additive
migration (`addColumn`; a nullable column needs no default). Deleting a document is not in Phase 3, but the FK is
defined so that it cannot leave a dangling link. One document can have several expenses (the user may split it); an
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
- A5. A document is never overwritten or deleted in Phase 3 (no edit/delete of documents). Deleting is small to add; I
  left it out because a deleted document must decide what happens to linked expenses (the FK already says `SET NULL`).
- A6. The expense-document link cannot be removed in Phase 3.
- A7. The `imports` table stores successful imports only. Failed and duplicate attempts live only in the one-time report.
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
