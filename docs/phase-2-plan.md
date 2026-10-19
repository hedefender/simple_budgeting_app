# Phase 2 plan: expenses (approved by the owner, 2026-10-19)

Decisions are in `docs/roadmap.md`, section "Phase 2 decisions". This file holds the plan that was approved with them.
Report at the end: `docs/reports/phase-2-report.md`.

## Architecture

New feature `lib/features/expenses/{domain,data,presentation}`, like `income`.

- **domain** (pure Dart): `Expense`, `ExpenseCategory`; `ExpenseRepository`, `CategoryRepository`; `ExpenseValidation`;
  use cases `CreateExpense`, `UpdateExpense`, `DeleteExpense`, `ListExpenses` (month and category filter),
  `GetExpenseTotals` (totals per currency). `Clock` and `IdGenerator` come through constructors.
- **data**: `ExpenseRepositoryImpl`, `CategoryRepositoryImpl` (drift).
- **presentation**: `ExpensesPage`, `ExpenseFormPage`, providers. The month and the category filter are their own
  providers. The month selector (previous/next buttons) is extracted from `IncomePage` into a shared `MonthSelector`
  widget. Expenses have their own `expenseMonthProvider`, independent of Income.
- A future `expense_lines` table (Phase 7) points to `expenses.id` with an additive migration. Nothing in `expenses`
  assumes that there are no lines.

## Schema v4

Before touching the schema: dump v3 to a temporary folder and compare it with `drift_schemas/drift_schema_v3.json`.
If they differ, STOP and tell the owner.

Then: `schemaVersion = 4`; `if (from < 4) { createTable(categories); createTable(expenses); }`; new dump; regenerate
`test/generated_migrations/`; retarget the existing migration tests to v4 and add v3 -> v4.

`categories`: `id` text PK, `category_key` text unique (not called `key`, an SQL keyword), `sort_order` int, `created_at` datetime. Built-in categories have
`id = key` (the same on every device, for the later sync; documented exception to the UUID rule). User categories
(Phase 5) get UUIDs and a nullable `name` column added then. Built-in names come from the ARB files by `key`.

`expenses`:

| Column | Type |
| --- | --- |
| `id` | text PK (UUID) |
| `description` | text, nullable |
| `category_id` | text, FK -> `categories.id` |
| `expense_date` | text `yyyy-MM-dd` |
| `currency_code` | text NOT NULL (currency of the account that was charged, also for a pending expense) |
| `amount_minor` | int, nullable (null = pending) |
| `original_amount_minor` | int, nullable |
| `original_currency_code` | text, nullable |
| `tax_amount_minor` | int, nullable (informational, in the account currency) |
| `created_at`, `updated_at` | datetime |

CHECK constraints (NULLs are handled explicitly, because a CHECK that evaluates to NULL passes in SQLite):

- `amount_minor IS NOT NULL OR (original_amount_minor IS NOT NULL AND original_currency_code IS NOT NULL)`
- `(original_amount_minor IS NULL) = (original_currency_code IS NULL)`
- `amount_minor IS NULL OR amount_minor > 0`
- `original_amount_minor IS NULL OR original_amount_minor > 0`
- `tax_amount_minor IS NULL OR tax_amount_minor > 0`

The domain validates the same rules (with messages) plus: tax <= total, tax only with an account amount, original
currency different from the account currency.

**Seed:** the built-in catalogue is a constant list in the data layer (`energy, water, telecom, food, fuel_transport,
health, insurance, other`), inserted with an idempotent `INSERT OR IGNORE` in `beforeOpen`. It covers a new install
and an upgrade, and a new category later is one line in the list, without a schema bump.

## Navigation

A third destination in the `NavigationBar` of `HomeShell`: Home | Income | Expenses. `ExpensesPage` has the month
selector, the category filter, the Settings button, and a floating button to add an expense.

## Cash flow

- `GetMonthlyCashFlow` gets an `ExpenseRepository` argument. `_balanceAt(day)` subtracts the non-pending expenses of
  the currency dated AFTER the anchor date and on or before `day`. Without an anchor all of them count. An expense
  dated ON the anchor day belongs to the anchor (the anchor is the balance at the END of its day, as for income).
- `MonthlyCashFlow` gets `expenses` (all non-pending expenses of the month in that currency, as the "received" line
  shows all income of the month) and `pendingExpenseCount`.
- `forAllCurrencies` also includes the currencies of expenses (pending too), so nothing is hidden.
- The cash flow card shows a line "Expenses" and, when there are pending expenses, "N expenses awaiting an amount
  (not counted)".

## Form

Description (optional), category (default "Other"), date (future dates allowed), account currency (the currencies in
the app plus "Other...", which uses the same ISO code validation as Settings), amount charged, collapsible "Original
amount and currency", collapsible "Of which VAT/taxes". If the account amount is empty and the original amount is
given, the form says that the expense is saved as "awaiting amount" and does not count. Delete is in the form, with a
confirmation.

## Steps (after each: `flutter analyze`, `flutter test`, `cargo test`; the app stays runnable)

| # | Step |
| --- | --- |
| 0 | Dump v3 and compare with the stored one (read only). |
| 1 | Schema v4: tables, CHECKs, migration, seed, new dump, generated helpers, migration tests. |
| 2 | Domain: entities, validation, interfaces, use cases, in-memory fakes, unit tests. |
| 3 | Data: drift repositories, DI, repository tests (including the failing CHECKs). |
| 4 | `GetMonthlyCashFlow` and entities: expenses in the balance, pending, currencies. Unit tests. |
| 5 | Cash flow card: "Expenses" line and pending indicator; ARB en/el; widget tests. |
| 6 | `ExpensesPage`: tab, list, `MonthSelector`, filter, totals per currency. |
| 7 | `ExpenseFormPage`: create, edit, pending, original amount, VAT, delete. |
| 8 | Docs (manual validation section 12, architecture), integration test file, `docs/reports/phase-2-report.md`. |

On-device tests run only with the owner's permission. Nothing is committed by Claude.

## Tests

- Unit: totals per currency; pending (saved, not counted, completed); anchor (before, ON, after; no anchor);
  several currencies never added; a currency that has only expenses; validation (no amount and no original amount, tax
  larger than total, zero, negative, same original currency).
- Repository (in-memory SQLite): CRUD, filters, seed (8 categories, none duplicated after a second open), FK, and the
  CHECKs must FAIL for: neither amount nor original amount; original amount without currency and the reverse; zero or
  negative amount (also original and tax).
- Migration v3 -> v4: data kept, new tables, seed present.
- Widget: expense form, pending (text and marker), category filter, delete with confirmation and cancel, "Expenses"
  line and pending indicator on the card, Greek and English.
- Integration (on device, only with permission): `integration_test/expense_persistence_test.dart`.

## Manual validation

Section 12 of `docs/manual-validation.md`. It must say that, with an anchor inside the month, the "Expenses" line is
not equal to the difference of the two balances (the same is already true for income).

## Assumptions and the owner's answers

1. Built-in category `id = key`. Approved.
2. The "Expenses" line shows all non-pending expenses of the month; the balance follows the anchor rule. Approved.
3. Only positive amounts. Refunds are entered as income "Other" for now; to be reconsidered in Phase 6. Approved.
4. VAT/taxes: account currency, only with an account amount, not larger than the total. Approved.
5. Account currency: currencies in the app plus "Other...", with the same ISO validation as Settings. Approved.
6. The original currency must differ from the account currency. Approved.
7. Free-text optional description. A nullable `vendor` column is added when the Scan JSON arrives. Approved.
8. Category default "Other". Approved.
9. Future dates allowed and counted in the projected balance. Approved.
10. Hard delete; tombstones come with sync. Approved.
11. `updated_at` is added now. Approved.
12. Separate selected month for Expenses. Approved.
