# Phase 2 report: expenses

Date: 2026-10-19. Not committed. Phase 2 is NOT marked Done: it waits for the owner's manual check
(`docs/manual-validation.md` section 12), which I did not do. Plan: `docs/phase-2-plan.md`. Decisions:
`docs/roadmap.md` ("Phase 2 decisions").

## Results of the final run

| Check | Result |
| --- | --- |
| `flutter analyze` | No issues found |
| `flutter test` | 464 passed, 0 failed (330 at the start of Phase 2) |
| `cargo test --manifest-path rust/Cargo.toml` | 2 passed |
| `integration_test/cold_start_test.dart` on emulator-5554 (Android 16, x86_64) | 2 passed |
| `integration_test/income_persistence_test.dart` on emulator-5554 | 2 passed |
| `integration_test/expense_persistence_test.dart` on emulator-5554 | 1 passed |

`flutter analyze`, `flutter test` and `cargo test` were run after every step (0-7) and at the end.

## Step 0: v3 dump

`dart run drift_dev schema dump` of the v3 code, written to a temporary folder, was byte-for-byte identical
(`cmp`) to `drift_schemas/drift_schema_v3.json`. So the work continued.

## What was built

1. **Schema v4** (`expense_tables.dart`, `app_database.dart`): tables `categories` and `expenses`, five CHECK
   constraints with explicit NULL handling, migration step `if (from < 4)`, new dump `drift_schema_v4.json`,
   regenerated helpers. The existing migration tests were retargeted to v4 (same data assertions); new group v3 -> v4.
   Built-in categories are inserted with `INSERT OR IGNORE` in `beforeOpen` (id = key).
2. **Domain** (`features/expenses/domain`): `Expense`, `OriginalAmount`, `ExpenseCategory`; `ExpenseRepository`,
   `CategoryRepository`; validation (`ExpenseValidationError`, 11 cases); `CreateExpense`, `UpdateExpense`,
   `DeleteExpense`, `ListExpenses`, `ListExpenseCategories`; `expenseTotalsByCurrency`.
3. **Data:** `ExpenseRepositoryImpl`, `CategoryRepositoryImpl`, DI registrations.
4. **Cash flow:** `GetMonthlyCashFlow` takes an `ExpenseRepository`; expenses after the anchor are subtracted; pending
   ones never; currencies of expenses are included in `forAllCurrencies`. `MonthlyCashFlow` has `expenses` and
   `pendingExpenseCount`.
5. **Cash flow card:** line "Expenses" and the pending indicator (ICU plural, English and Greek).
6. **Expenses page:** third tab, month selector (extracted to `core/presentation/month_selector.dart`, shared with
   Income), category filter, totals per currency (primary first), list with the pending marker.
7. **Expense form:** add, edit, delete with confirmation; collapsible original amount and VAT/taxes; the pending
   notice; account currencies = those in the app + "Other..." (same ISO validation as Settings, via the existing
   `CurrencyDropdown`, which got a `fieldKey`).
8. Docs (`architecture.md`, `manual-validation.md` section 12, this report) and the on-device test file.

## Follow-up after the first emulator check: balance start

Found by the owner: a balance of 780 on 12 Oct and an expense of 98 dated 24 Sep gave September an opening balance of
0 and a closing balance of -98, a number the app cannot know. Decisions: `docs/roadmap.md` ("Balance start").

- `BalanceStart` / `GetBalanceStart`: oldest anchor of the currency, else oldest source (archived too), else none.
  Computed every time, not stored. No schema change.
- `MonthlyCashFlow.balanceStart` and `balanceUnknown` (the month ends before the start). The card shows "—" for the
  opening and closing balance and "The balance starts on <date>"; income and expense lines stay visible.
- Behavior change you approved: expenses dated before the start no longer count in a balance, also without an anchor.
- Expense form: non-blocking warning computed on every build (anchor start: date on or before the anchor day, button
  proposes the next day; source start: date before it, button proposes that day). It follows the date and the
  account currency.
- Bottom padding of the Income and Expenses lists is now computed from the size of the floating button, its margins and
  the bottom inset (`core/presentation/fab_clearance.dart`; it was a fixed 96). The test with 25 rows passes, but it
  also passed with 96, so I cannot tell from tests alone why the button covered the last row on the emulator. Please
  check it by eye.
- Tests added: 16 unit and card tests (start from anchor / source / none / several currencies, month before, start
  month, month after) and 9 widget tests for the form warning, 2 for the padding. The earlier `app_test` etc. unchanged.

## Differences from the plan

- **`GetExpenseTotals` is a pure function** (`expenseTotalsByCurrency`) called by `ListExpenses`, not a separate use
  case: the totals must follow the same filter as the list.
- **Column `category_key`**, not `key` (`key` is an SQL keyword). The plan file was corrected.
- **New use case `ListKnownCurrencies`** (settings domain): the currencies in sources, anchors and expenses, primary first.
  Needed for the account-currency dropdown (Q5).
- **A bug found by an existing test and fixed:** the Income and Expenses tabs both have a floating button and both
  tabs are alive in the shell, so they shared Flutter's default hero tag and every page transition (the wizard, the
  forms) threw. The Expenses button has its own `heroTag`. Caught by `app_test.dart` (first-run wizard).
- The original currency in the form defaults to the first common currency that differs from the account currency and
  follows the account currency until the user picks one explicitly.

## Tests added (103)

- Migration v3 -> v4 (4): data kept, empty `expenses`, eight categories with id = key, an expense can be stored.
- Domain unit (29): create, validation (every error), update (completes a pending expense), delete, list (month,
  newest first, category filter, totals per currency, primary first, pending counted separately, only-pending currency).
- Cash flow unit (15): no anchor; anchor before / ON / after; opening balance of the next month; the line is not the
  balance difference with an anchor inside the month; pending; several currencies; currencies that have only expenses.
- Repository (18): CRUD and round trip of every field, ordering, inclusive date range, category filter, currency codes,
  seed (eight categories; a second open of the SAME file does not duplicate), foreign key, and the CHECK constraints
  that must fail: neither amount nor original amount; original amount without currency and the reverse; zero or
  negative amount; zero or negative original amount or tax.
- Widget: card (6), Expenses page (11), expense form (20) including pending (save, complete, clear both), VAT, original
  currency, currencies list, "Other...", delete (cancel/confirm), edit, refresh of the Income cash flow, Greek.
  `app_test.dart` was extended earlier for the wizard; it also exercises the three-tab shell.
- Integration (on device, not run): `expense_persistence_test.dart`.

## Not verified

- The on-device tests do not open the screens. The manual check of section 12 is the owner's.
- The Greek texts of the Expenses page and form have not been seen on a screen.
- With an anchor inside the month the "Expenses" line is not the difference of the two balances (intended; written in
  section 12, step 5).
- Known limits: hard delete (no tombstones until sync); only positive amounts (refunds are income "Other", to be
  reconsidered in Phase 6); the date picker of the expense form is not covered by a widget test; the category names of
  a future category without an ARB entry show its key.

## What the owner has to commit

Schema and generated files that MUST be in the commit (a missing one breaks the migration tests or the build):

- `drift_schemas/drift_schema_v4.json` (new). `drift_schema_v1.json`, `_v2.json`, `_v3.json` are unchanged and
  already committed.
- `test/generated_migrations/schema_v4.dart` (new) and `test/generated_migrations/schema.dart` (modified; it lists
  the versions). `schema_v1.dart`, `schema_v2.dart`, `schema_v3.dart` are unchanged.
- `lib/core/database/app_database.g.dart` (modified; this repo tracks it).
- `lib/l10n/app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_el.dart` (modified; tracked
  generated files of `flutter gen-l10n`).

Everything else is source: new `lib/features/expenses/**`, `lib/core/presentation/month_selector.dart`,
`lib/core/database/seed/`, `lib/core/database/tables/expense_tables.dart`,
`lib/features/settings/domain/usecases/list_known_currencies.dart`, `integration_test/expense_persistence_test.dart`,
new tests under `test/`, and the changed docs (`roadmap.md`, `phase-2-plan.md`, `architecture.md`,
`manual-validation.md`, this report). Check with `git status` before committing.
