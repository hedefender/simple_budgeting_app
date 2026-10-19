# Phase 1c report: currency handling

Date: 2026-10-19. Not committed. Phase 1c is marked Done in `docs/roadmap.md` after the owner's manual check (section 10 of
`docs/manual-validation.md`), which the owner did and reported as finished (I did not do it myself).

## Problem

After the device region changed (el_GR/EUR to en_US/USD) the Income page showed 0 and "No payments this month" while
the sources were in EUR, because the cash flow filtered by the device currency. Data was hidden silently.

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 294 passed, 0 failed (266 at the start of 1c) |
| `cargo test --manifest-path rust/Cargo.toml` | 2 passed |
| `integration_test/income_persistence_test.dart` on emulator-5554 | 2 passed (the second test is new). Run once, see "What went wrong" |
| `integration_test/cold_start_test.dart` on emulator-5554 | 2 passed (run once, before the Settings page was added) |

## What was built (steps 1-7)

1. **`primary_currency`** (`SettingsRepository`, `GetPrimaryCurrency`, `SetPrimaryCurrency`). Stored in `app_settings`,
   so there is no schema change and no migration. First value: the currency of the oldest existing source, else the
   device currency. It never follows the device afterwards. A code is accepted when it is 3 letters (upper-cased);
   it is not checked against the ISO 4217 list.
2. **Cash flow per currency** (`GetMonthlyCashFlow.forAllCurrencies`, `MonthlyCashFlowSummary`). One cash flow for
   every currency in sources (archived too) and anchors, plus the primary (always present). Primary first, the rest
   sorted by code. One shared payment list. New `BalanceAnchorRepository.listCurrencyCodes()`.
3. **Currency in the forms.** The source form has a currency dropdown on creation (default: primary) and a read-only
   currency when editing. The balance dialog has a currency switch when more than one currency is shown and returns
   the chosen currency. Shared `CurrencyDropdown` (16 common codes and "Other...").
4. **Income page.** One card per currency (opening balance, received, expected, projected closing balance, and its own
   "Set balance"), all payments listed with their own currency. Card values are formatted with the card's currency
   (before they used the device currency).
5. **Settings page** (icon in the app bar of Home and Income): the primary currency.
6. **`scheduleSummary`:** Greek "5η εργάσιμη"; the shift rule is appended when it is not "none" and it can apply
   (not for one-off and not for schedules made only of Nth working days).
7. Docs (`roadmap.md`, `architecture.md`, `manual-validation.md` section 10) and this report.

Money is not converted anywhere. Amounts of different currencies are never added.

## Tests added (28)

- Unit: `GetPrimaryCurrency` / `SetPrimaryCurrency` (6), cash flow per currency (5: order, primary first, shared list,
  device change does not hide data, empty primary, anchor-only and archived currencies).
- Data: `SettingsRepositoryImpl` (2), `listCurrencyCodes` (1).
- Widget (`currency_screens_test.dart`, 13): source form currency (default, choose, other code, read only), balance
  dialog currency (2), Income page with several currencies (4, including the reported bug), Settings (3). Plus one
  summary test for the shift rule, and the existing tests updated for the new keys (`cash-closing-USD`) and the Greek
  "η εργάσιμη".
- Integration: sources in two currencies and the primary survive a restart (uses a temporary database file).

## Assumptions of the plan and how they held

All nine held. Differences from the plan:

- No ICU `select`/`plural` was needed: the Greek "η" ending is right for every number 1-23.
- The public `GetMonthlyCashFlow.call(month, currency)` stays (the domain tests use it); the UI no longer does.
- A migration or schema dump was not needed.

## What went wrong

- Running `flutter test integration_test/... -d emulator-5554` (and once without `-d`, which picked the only connected
  device) installs the app again and DELETES the app's data on the emulator (`Launch #1` on the next start). I ran it
  three times in this phase; the owner saw an empty database each time. The integration test itself uses a temporary
  database file, but the reinstall deletes the app's own data. The warning is now in `docs/manual-validation.md`.
  I should not have run on-device tests without warning first.

## Could not run / not verified

- The manual steps (`docs/manual-validation.md`, section 10) were NOT performed by me. The UI was not looked at on
  screen; the Settings page, the dropdowns and the cards were checked only with widget tests.
- The upgrade from a real Phase 1b install (step 11) was not tested on a device. There is no schema change, and the
  rule "primary = currency of the oldest source" is covered by a unit test only.
- Nothing was run on a physical phone.
- Money formatting of rare currencies (decimals, symbols) relies on `intl`; only EUR, USD, GBP, CHF/NOK/NZD codes
  were used in tests.

## For the planning discussion later (ideas from the owner, not started)

1. **Protect the database from accidental deletion and reinstall.** The user's data should survive an uninstall,
   a reinstall or "clear data" by mistake, and the app should offer to restore it when a copy exists. Owner's
   direction: the copy belongs to the user and lives where the user chooses; encryption, if any, is the cloud
   provider's business; the app produces the database file and can export to a spreadsheet. Open questions
   (roadmap open decision #15): file format of the copy, CSV or XLSX, when the copy is made, how the restore is
   offered on the first start.
2. Currency conversion with manual rates (open decision #11 in the roadmap).
3. Show the currency code next to payment amounts when several currencies share a symbol (for example USD and CAD).
4. Integration test of the Settings page and the multi-currency cards on a device, once the owner decides how to
   keep the emulator data (see "What went wrong").
5. CLAUDE.md privacy section: align the wording about network access with the new principle in roadmap decision #11
   ("no infrastructure of our own, no personal data sent").
