# Phase 1d report: setup wizard and extra payments

Date: 2026-10-19. Not committed. Phase 1d is Done: the owner did the manual check of `docs/manual-validation.md`
section 11 and it passed (I did not do it myself).

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 330 passed, 0 failed (294 at the start of 1d) |
| `cargo test --manifest-path rust/Cargo.toml` | 2 passed |
| `integration_test/cold_start_test.dart` on emulator-5554 (Android 16, x86_64) | 2 passed |
| `integration_test/income_persistence_test.dart` on emulator-5554 | 2 passed |

The on-device tests do not open the wizard; that was checked by hand by the owner (section 11 passed).
`cold_start_test.dart` was edited (see below) and passes on the emulator.

## Owner's changes to the plan, and how they were applied

1. **No schema v4.** Nothing "unconfirmed" is stored. The wizard shows the preset lines as "Suggested" with an empty
   amount; a source is created only for lines that are ticked and have an amount. No `preset_key`/`confirmed_at`.
   Running the wizard again warns (it does not block) when an active source has the same name (case and surrounding
   spaces ignored; archived sources do not count).
2. **`IncomeType.extraPayment`** added at the END of the enum. Checked before coding: the type is stored as text
   (`type.name` in `IncomeRepositoryImpl`, read with `IncomeType.values.byName`), so no migration was needed. The
   schema is still v3.
3. **Decisions 1-8:** empty amount with helper text (Christmas "up to the net salary", Easter "up to half"), deadlines
   21 December and Holy Wednesday with "previous working day", the leave allowance is optional (unticked, the user
   gives month and day), manual amounts only, no public-sector preset (the wizard says the suggestions are for the
   private sector), the button "Add another yearly payment", `lastVerified` only in the wizard.
4. **`docs/roadmap.md`:** decisions in "Phase 1d decisions"; the possible schema v4 is gone.

## What was built

1. **`Yearly` schedule** (`income_schedule.dart`): anchor `FixedDate(month, day)` (29 February becomes the last day in
   a common year) or `EasterRelative(offsetDays)` (Holy Wednesday = -4), plus a shift rule. Handled by the engine
   (`schedule_engine.dart`) and the codec (`"type":"yearly"` inside JSON version 2: an addition, so no version bump).
2. **Orthodox Easter moved to the domain** (`orthodox_easter.dart`) because the engine needs it.
   `GreekHolidayCalendar.orthodoxEaster` and `julianGregorianOffsetDays` delegate to it, so the old tests still apply.
3. **Source form:** a fifth schedule choice "Yearly" (fixed month and day, or Holy Wednesday; an Easter offset other
   than -4, if a source has one, is kept and shown). `scheduleSummary` and `IncomeType` labels in en/el.
4. **Preset pack** as data in Dart (`features/setup/domain/greek_preset_pack.dart`, `lastVerified` 2026-10-19, source
   ids from `docs/extra-payments.md`). Only employees get lines.
5. **Setup wizard** (`features/setup/presentation/setup_wizard_page.dart`): profile choice (employee, freelancer,
   side hustle), one regular income line (monthly, day of the month, previous working day), the suggestions, custom
   yearly lines. Typing an amount ticks its line. A ticked line needs a name and a positive amount.
6. **First-run trigger:** `setup_completed` in `app_settings` (no schema change). The wizard opens by itself from
   `HomeShell` only when it was never finished or skipped AND there are no sources (an install from before 1d does
   not see it). Settings has an entry to run it again.

## Choices I made that were not in your message

- **Start date** of every source created by the wizard is today, so no history is created.
- **Currency** is the primary currency; the wizard has no currency choice. Use the source form for another one.
- **Regular income line** is also unticked by default, to follow the rule "only what the user ticks".
- **Custom yearly lines** use a fixed month and day with the shift "previous working day"; the shift and an Easter
  anchor can be changed afterwards in the source form.
- **Leaving the wizard with the back button** does not mark it completed, so it opens again at the next start. Only
  "Create sources" and "Skip for now" complete it.
- I did not have the original 1d plan after `/clear`; I rebuilt the steps from your message and from `docs/roadmap.md`
  and `docs/extra-payments.md`. If the plan had something else in it (for example another step order), tell me.

## Tests added

- Unit: `yearly_schedule_test.dart` (engine for 21 December across weekdays, 29 February, a shift into the previous
  month, Holy Wednesday 2025/2026/2027, an offset into the next month; codec round trip, exact JSON, 8 malformed
  inputs), `SettingsRepositoryImpl` setup flag.
- Widget: `setup_wizard_test.dart` (suggestions with empty amounts, English and Greek, freelancer, creation of exactly the
  ticked lines with the right types and schedules, validation, skip, leave allowance, custom line, duplicate warning
  incl. archived and non-blocking), first-run behaviour in `app_test.dart` (opens, not again, not with sources, not when
  completed), two Yearly tests in the source form.
- Existing tests changed: `app_test.dart` marks the setup as completed by default; `FakeSettingsRepository` and
  `registerIncomeFakes` know the new use cases.

## Not verified

- `integration_test/cold_start_test.dart` now marks the setup completed first (otherwise the wizard would cover Home
  on a fresh install and the test would not find `launch-count`); the edit passes on the emulator.
- The Greek texts of the wizard were seen by the owner during the manual check, which passed.
- The legal facts behind the suggestions are as confirmed (or not) in `docs/extra-payments.md`; I did not check them
  again.
- Known limit: the leave allowance has no "usual" date, so the pickers start on today's date and the user must change
  them.
- `dart format` was run on the touched folders; the files it changed are all ones I edited (checked with `git status`).
