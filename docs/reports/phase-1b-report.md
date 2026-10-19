# Phase 1b report

Date: 2026-10-19. Not committed. Phase 1b is NOT marked Done in `docs/roadmap.md` (it says "Next"); the owner confirms.

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 266 passed, 0 failed (224 at the end of stage 1, 147 at the end of 1a) |
| `cargo test --manifest-path rust/Cargo.toml` | 2 passed |
| `integration_test/income_persistence_test.dart` on emulator-5554 | 1 passed (now also checks a pinned date after a restart) |
| `integration_test/cold_start_test.dart` on emulator-5554 | 2 passed |

Test files by area (number of `test(...)` calls; looped tests such as the 20 Easter years make the real total higher
than the sum, 266): core 49, income domain 117, income data 37, widget 28, app 6, foundation 6, host integration 3.

## Stage 1 (reported earlier)

DayRule, ShiftRule, Weekly, Monthly, SeveralPerMonth, WorkingDays, HolidayCalendar, GreekHolidayCalendar
(`docs/holidays.md`), ScheduleEngine with (nominal, actual) pairs, codec v2 with v1 backward compatibility.

## Stage 2

- **Schema v3** (`income_entries.actual_date`, nullable text). Before the change I checked that the freshly dumped
  v2 schema is byte-identical to `drift_schemas/drift_schema_v2.json`. Then dump v3, regenerated migration helpers.
  Migration: `from == 2` adds the column and backfills `actual_date = original_date` only for entries on or before
  the source's `frozen_through` (Phase 1a had no shifting, so that is exactly the date they were paid). A v1
  database gets the tables in their v3 shape, so only `from == 2` runs the new step.
  Migration tests: v1 -> v3, v2 -> v3 backfill (pinned inside the frozen range, not after it, not for never-frozen
  sources), no row lost, new rows can use the column.
- **Actual dates everywhere** (`IncomeCalculator`): the month of a payment, received/expected, balances and anchors,
  and the start/end/archive/frozen limits use the actual date. Actions and the UI keys use the nominal date
  (`IncomeOccurrence.nominalDate`). Entries are matched on the nominal date, so a later correction of the holiday
  calendar does not orphan them (tested).
- **Pinned entries** (`actual_date` set) are shown whatever the source limits are (they are decisions or frozen
  history) and are not duplicated when the schedule also produces the payment.
- **Freeze on edit** now pins every payment up to today with the date it was paid (also existing skipped/changed
  entries); a schedule, shift or amount change keeps history where it was paid.
- **Change a payment's date** (optional item 5): the dialog has the amount and a date; the date is pinned only when
  the user changed it. Changing the amount or skipping later keeps the pin; "restore" removes it.
- **Form**: frequency (once, monthly, several a month, weekly), day rule (day of the month, last day, Nth working
  day), add/remove rules (2 to 6), weekday, shift rule (hidden when every rule is a Nth working day), duplicate
  rules rejected. Summaries for every schedule kind in en and el; `Monthly` with a Nth working day is no longer
  shown as "last day". The `UnimplementedError`s are gone.

## Tests added in stage 2

- Domain (`shifted_income_test.dart`, 23): cross-month shifted payments, anchors on/around the actual date, skip and
  amount on the nominal date, calendar correction, pinned date moves/keeps/clears, freeze keeps actual dates, new
  schedule kinds in the cash flow.
- Data: pinned actual date round trip and clearing; migration tests (above).
- Widget: frequency selection, add/remove rules, shift hidden/shown, duplicates, weekly and Nth working day saved,
  "Do not move", editing a several-per-month source, change payment dialog (amount only; date pinned), summaries
  for every case in en and el (`schedule_summary_test.dart`).

## Deviations and notes

- A payment whose shifted date falls before the source's start date is not generated (assumption 6). Example: a
  source starting 1 Jan 2026 with day 1 and "previous working day" has no January payment (1 Jan is a holiday and
  moves to 31 Dec 2025). Tests document this.
- The Nth working day dropdown offers 1-20 (domain allows up to 23); an existing value above 20 is kept.
- The weekday names in the form come from `intl` (`DateFormat.EEEE`).
- `docs/holidays.md` keeps the stage 1 list of what was and was not confirmed (1 May moves, sector differences).
- A pinned entry for a source that was archived or ended is still shown (it is the user's decision).
- Weekly and several-per-month payments with the same actual date are separate payments.
- `dart format` was run only on files I changed or created.

## Could not run / not verified

- The UI was not looked at on screen; the manual validation steps (`docs/manual-validation.md`, section 9) were NOT
  performed by me.
- Nothing was run on a physical phone, only the x86_64 emulator.
- The official legal texts for the holidays were not read (see `docs/holidays.md`).
- The upgrade path from a real Phase 1a install (step 13 of the manual list) was tested only by the migration tests,
  not on a device.
