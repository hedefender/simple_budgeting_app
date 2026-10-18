# Phase 1a report (not for commit)

Date: 2026-10-19. Not committed. Phase 1a is NOT marked Done in `docs/roadmap.md` (it still says "Next").

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 147 passed, 0 failed |
| `cargo test --manifest-path rust/Cargo.toml` | 2 passed |
| `integration_test/income_persistence_test.dart` on emulator-5554 | 1 passed |
| `integration_test/cold_start_test.dart` on emulator-5554 | 2 passed |

## Tests by category (`flutter test`: 147)

| Category | Count |
| --- | --- |
| core (money, MoneyParser, CalendarDate/YearMonth, migration) | 46 |
| income domain (ScheduleEngine, use cases, GetMonthlyCashFlow) | 52 |
| income data (schedule codec, repositories with in-memory drift, FK, unique keys, freeze history) | 20 |
| widget (3 Phase 0 app tests + 11 Income screens: form validation, Greek `12,50`/`12.50`, end before start, use case error message en/el, received/expected, skip changes totals, balance dialog) | 14 |
| app (bootstrapper, service locator) | 6 |
| foundation | 6 |
| host integration (`test/integration`) | 3 |
| on device (not in the 147) | 3 (2 cold start, 1 income persistence) |

## Implemented, per step of the plan

- Step 0 docs: roadmap split into 1a/1b/1c/2b, Phase 1a decisions, weekend/holiday rule recorded as decided,
  tax note, currency known limit; CLAUDE.md rules (net amounts, instants vs `CalendarDate`, schedule logic in
  Dart, drift schema workflow, "never run dart format on the whole project").
- Step 1.1 `MoneyParser` (+ `formatMoneyForInput`): locale aware, currency decimals, no rounding.
- Step 1.2 Drift v2: `income_sources`, `income_entries`, `balance_anchors`; `stepByStep`-style `onUpgrade`
  (`createTable` for the three tables); `drift_schemas/` v1 (dumped BEFORE changing tables) and v2;
  generated migration helpers in `test/generated_migrations/`.
- Step 1.3 `IncomeSchedule` sealed class (`OneOff`, `Monthly`), JSON codec in the data layer, unknown type or
  version throws `ScheduleDecodeException`.
- Step 1.4 `ScheduleEngine.occurrencesInMonth`; day 29-31 falls on the month's last day.
- Step 1.5 Occurrences are computed (`IncomeCalculator`); `income_entries` stores only skipped/changed/frozen ones.
- Step 1.6 Use cases: create, update, archive, list, monthly cash flow, change amount, skip, reset, set anchor.
- Step 1.7 UI: bottom navigation (Home, Income), Income page, source form, payment menu, balance dialog, ARB en/el.
- Step 1.8 Tests: see above.

## Your changes 1-8

1. Multiple anchors; anchor = balance at END of its day; balance(D) = last anchor <= D plus income dated after
   it; an in-month anchor affects that month; no anchor means 0 plus all income since the source start. Done
   (`GetMonthlyCashFlow`, tests for in-month anchor and same-day income).
2. "Received" = computed occurrence dated <= today (injected clock) unless skipped; a changed amount is used;
   later ones are expected. `income_entries` has `status` (received/skipped) and `amount_minor`. Done.
3. `start_date` required (default today in the form), optional `end_date`; nothing generated before start, after
   end or after archiving. Done.
4. Freeze history on edit (amount or schedule change): done in `UpdateIncomeSource`, via a new source column
   `frozen_through`. The "known limit" about schedule changes is not in the docs.
5. `CalendarDate` and `YearMonth` in `lib/core/time`, stored as `yyyy-MM-dd` text, arithmetic in `DateTime.utc`;
   CLAUDE.md line added; UTC+3 no-shift test added.
6. Schema v1 dumped before the change; `PRAGMA foreign_keys = ON` was already in `beforeOpen`; test added.
7. MoneyParser: decimals from the currency; `12.50` accepted in el; `1.234` in el = 1234,00 (group separator,
   decided by the locale rule: exactly 3 digits, 1-3 leading digits, no leading zero, and the separator is the
   locale's group separator); `1.234` in a 2-decimal field is never read as 1,234. Negatives via the
   `allowNegative` parameter.
8. `YearMonth`/`CalendarDate` in `lib/core`; codec in `lib/features/income/data`; domain has no JSON.

## Not implemented, or deviating from the plan

- Widget tests for the Income screens now exist (`test/widget/income_screens_test.dart`, 11 tests). Layout is not
  tested. The month navigation, source list tap-to-edit, archive dialog and the payment "change amount" dialog have
  no widget test.
- `build.yaml` with `schema_dir` was not added; the schema dump and `schema generate` are run by hand (command in
  CLAUDE.md).
- Migration test covers v1 -> v2 with data kept. It does not compare a fresh v2 install to the dump separately
  (`migrateAndValidate` validates the migrated schema against the v2 dump).
- Extras not in the plan: `frozen_through` column, `Clock` registered in get_it, `IdGenerator`/`generateUuidV4`,
  `SkipOccurrence`/`ResetOccurrence` use cases, `formatMoneyForInput`.
- A use case validation error in the source form now shows its own message (ARB en/el: name, amount, end date,
  source not found, source archived), tested for "archived" in en and el.
- The "today" calendar day and the archive day use the device's local offset (`CalendarDate.fromInstant`
  without `offset`); only tests inject an offset.
- Editing is blocked for archived sources (no un-archive in 1a).
- Currency of a source is the device currency at creation; no per-source currency choice in the UI.
- Not in 1a by design: weekly or multiple payments, working days, holidays, extra payments, presets, month close.

## Could not run / not verified

- Nothing was run on a physical phone or an ARM device (only the x86_64 emulator).
- The manual validation steps (`docs/manual-validation.md`, section 8) were NOT performed by me; the UI was never
  looked at on screen.
- No profile-build startup measurement.
- The income integration test now uses a temporary database file that it deletes, so it leaves nothing behind.
  An earlier run of the old version DID leave one CHF source "Test salary ..." in the emulator's app database;
  clear the app data of the emulator to remove it (I did not).

## Formatting scope

Early on I ran `dart format lib` and `dart format test` (against the new rule). They reformatted existing files
outside scope; I reverted these with `git checkout` (formatting only, no functional change was lost):
`lib/app/bootstrap/{bootstrap_controller,bootstrap_page,bootstrapper}.dart`, `lib/app/di/providers.dart`,
`lib/core/money/money_formatter.dart`, `lib/features/foundation/{data,domain}/...` (3 files),
`test/app/bootstrap/bootstrapper_test.dart`, `test/app/di/service_locator_test.dart`,
`test/features/foundation/domain/usecases_test.dart`. The remaining modified tracked files contain intended
changes (checked with `git diff`).
